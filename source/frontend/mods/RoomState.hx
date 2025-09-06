package frontend.mods;

import game.battle.BattleSubState;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import backend.game.Ally;
import flixel.util.FlxSort;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.tiled.*;
import backend.game.Party;
import flixel.FlxCamera;

class RoomState extends FlxState
{
    public var party:Party;
    public var room:String;
    public var map:TiledMap;
    public var colliders:Array<FlxObject> = [];
    public var startPos:FlxPoint;
    public var zSortableGroup:FlxTypedGroup<FlxObject> = new FlxTypedGroup<FlxObject>();

    public var inBattle:Bool = false;

    public var gameCAM:FlxCamera;
    public var hudCAM:FlxCamera = new FlxCamera();

    //-----Initialization-----//

    override public function new(room:String, party:Party)
    {
        super();
        this.party = party;
        this.room = room;
    }

    override public function create() {
        super.create();
        loadTilemap();
        add(zSortableGroup);
        initParty();

        gameCAM = FlxG.camera;

        FlxG.cameras.add(hudCAM, false);
        hudCAM.bgColor = 0x00000000;
    }

    function initParty()
    {
        // Rearrange members so leader is first, followed by others in original order (excluding leader)
        var followers = [for (member in party.members) if (member != party.leader) member];
        party.members = [party.leader].concat(followers);

        for (memberID in 0...party.members.length)
        {
            var member = party.members[memberID];
            member.setPosition(startPos.x, startPos.y);
            zSortableGroup.add(member);
            if (member != party.leader)
                member.delay = memberID * 20;
            member.updateHitbox();
            member.adjustedHitbox = true;
        }

        FlxG.camera.follow(party.leader, LOCKON, 1);
        FlxG.camera.focusOn(party.leader.getPosition());
        FlxG.camera.zoom = 1;
    }

    function loadTilemap()
    {
        var path = Asset.room('$room');
        map = new TiledMap('$path/${room.split('/')[1]}.tmx', '$path/');
        var zLayers:Array<{layer:FlxTilemap, id:Int, objLayer:TiledObjectLayer}> = [];
        for (layer in map.layers) {
            if (layer is TiledTileLayer) {
                var tileLayer:TiledTileLayer = cast layer;
                var tilemap = new FlxTilemap();
                var rawData = tileLayer.tileArray;
                var adjustedData:Array<Int> = [];
                for (id in rawData)
                    adjustedData.push(id > 0 ? id - 1 : -1);
                tilemap.loadMapFromArray(
                    adjustedData,
                    tileLayer.width,
                    tileLayer.height,
                    '$path/' + map.getTileSet(room.split('/')[1]).imageSource,
                    map.tileWidth,
                    map.tileHeight
                );
                if (layer.name.startsWith('_ZLAYER'))
                {
                    var id = Std.parseInt(layer.name.substring(7));
                    var set = false;
                    for (layer in zLayers)
                    {
                        if (layer.id == id)
                        {
                            layer.layer = tilemap;
                            set = true;
                            break;
                        }
                    }
                    if (!set)
                        zLayers.push({layer: tilemap, id: id, objLayer: null});
                } else
                    add(tilemap);
            } else {
                if (layer is TiledObjectLayer)
                {
                    var objLayer:TiledObjectLayer = cast layer;
                    var set = false;
                    if (objLayer.name.startsWith('_ZLAYER'))
                    {
                        var id = Std.parseInt(objLayer.name.substring(7));
                        for (layer in zLayers)
                        {
                            if (layer.id == id)
                            {
                                layer.objLayer = objLayer;
                                set = true;
                                break;
                            }
                        }
                        if (!set)
                            zLayers.push({layer: null, id: id, objLayer: objLayer});
                    } else {
                        if (objLayer.name.startsWith('_COLLIDERS'))
                        {
                            for (obj in objLayer.objects) {
                                var collider = new FlxObject(obj.x, obj.y, obj.width, obj.height);
                                collider.immovable = true;
                                colliders.push(collider);
                            }
                        } else if (objLayer.name.startsWith('_SPAWN'))
                        {
                            for (obj in objLayer.objects)
                                startPos = new FlxPoint(obj.x, obj.y);
                        }
                    }
                }
            }
        }
        for (zLayer in zLayers)
        {
            if (zLayer.layer == null || zLayer.objLayer == null) {
                Logger.error('ZLayer ' + zLayer.id + ' has no layer or object layer to pair with it. This layer will fail to load and become invisible.');
                continue;
            }
            for (obj in zLayer.objLayer.objects) {
                var poly = obj.points;
                var tileLayer = zLayer.layer;
                var x = tileLayer.x;
                var y = tileLayer.y;
                var tileSize = tileLayer.tileWidth;
                var polygon = poly.map(p -> new FlxPoint(p.x + obj.x, p.y + obj.y));
                var zGroup = ZLayerBuilder.buildZLayerGroup(polygon, tileLayer, tileSize, x, y);
                zSortableGroup.add(zGroup);
            }
        }
    }

    //-----Update-----//

    var debugTrig:Bool = false;
    override public function update(elapsed:Float) {
        if(inBattle) return;
        super.update(elapsed);
        for (member in party.members) {
            if (member != party.leader) {
                var newPos = new FlxPoint(party.leader.x, party.leader.y);
                if (member.targetTrail.length == 0 || !member.targetTrail[member.targetTrail.length - 1].equals(newPos)) {
                    member.targetTrail.push(newPos);
                }
            } else {
                movement();
                collision();
            }
        }
        // z layering
        zSortableGroup.sort(sortByDepth);

        #if debug
        if (FlxG.keys.justPressed.B) callBattle();

        if(FlxG.keys.justPressed.L)
            for(member in party.members)
                Logger.debug('Member: ${member.mainName}, Pos: (${member.x}, ${member.y}), Trail Length: ${member.targetTrail.length}');

        if(FlxG.keys.justPressed.T)
        {
            debugTrig = !debugTrig;
            for(member in party.members)
            {
                member.variant = debugTrig ? 'battle' : 'normal';
                member.animation.play(debugTrig ? 'fight-engage' : 'walk-right', true);
            }

            if(debugTrig)
                gameCAM.follow(null);
            else
                gameCAM.follow(party.leader, LOCKON, 1);
        }

        if(FlxG.keys.justPressed.PLUS)
            for(member in party.members)
                member.x += 50;
        #end
    }

    function sortByDepth(order:Int, a:FlxObject, b:FlxObject):Int
    {
        var sortYA = getSortY(a);
        var sortYB = getSortY(b);
        return FlxSort.byValues(order, sortYA, sortYB);
    }

    function getSortY(obj:FlxObject):Float
    {
        if(obj == null) return 0;
        if (Std.isOfType(obj, FlxSpriteGroup))
        {
            var group:FlxSpriteGroup = cast obj;
            var maxBottom:Float = Math.NEGATIVE_INFINITY;
            for (member in group.members)
            {
                if (member != null && member.exists && member.visible)
                {
                    maxBottom = Math.max(maxBottom, member.y + member.height);
                }
            }
            return (maxBottom == Math.NEGATIVE_INFINITY) ? obj.y + obj.height : maxBottom;
        }
        return obj.y + obj.height;
    }

    function movement() {
        var leader = party.leader;
        var isRunning = FlxG.keys.pressed.SHIFT;
        var speed = isRunning ? 2.0 : 1.0;

        var moveX:Float = 0;
        var moveY:Float = 0;

        if (FlxG.keys.pressed.RIGHT) moveX += 1;
        if (FlxG.keys.pressed.LEFT) moveX -= 1;
        if (FlxG.keys.pressed.DOWN) moveY += 1;
        if (FlxG.keys.pressed.UP) moveY -= 1;

        if (moveX != 0 || moveY != 0) {
            var length = Math.sqrt(moveX * moveX + moveY * moveY);
            moveX /= length;
            moveY /= length;

            leader.x += moveX * speed;
            leader.y += moveY * speed;

            var dir = if (Math.abs(moveX) > Math.abs(moveY)) (moveX > 0 ? "right" : "left") else (moveY > 0 ? "down" : "up");
            leader.animation.play("walk-" + dir);
            leader.animation.curAnim.frameRate = 12 * (isRunning ? 1.5 : 1.0);
        } else {
            if (leader.animation.curAnim != null) {
                leader.animation.curAnim.pause();
            }
        }
    }

    var tension:FlxSound;
    public function callBattle():Void
    {
        inBattle = true;
        tension = new FlxSound().loadEmbedded(Asset.sound('sounds/battle/tensionhorn.wav'), false);
        tension.play();

        // timer for the tension sfx
        new FlxTimer().start(0.3, _ -> {
            if (tension.playing) tension.stop();
            tension.pitch += 0.1;
            tension.play();
        }, 1);

        // open the battle substate
        new FlxTimer().start(0.8, _ -> {
            for (member in party.members)
                if (zSortableGroup.members.contains(member))
                    zSortableGroup.remove(member);
            
            gameCAM.follow(null);
            openSubState(new BattleSubState('RoaringKnight', party, hudCAM, zSortableGroup));
        });
    }

    function collision() {
        for (collider in colliders)
            FlxG.collide(party.leader, collider);
    }
}