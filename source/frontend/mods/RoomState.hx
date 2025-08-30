package frontend.mods;

import backend.game.Ally;
import flixel.util.FlxSort;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxSpriteGroup;
import flixel.addons.editors.tiled.*;
import backend.game.Party;

class RoomState extends FlxState
{
    public var party:Party;
    public var room:String;
    public var map:TiledMap;
    public var colliders:Array<FlxObject> = [];
    public var startPos:FlxPoint;
    public var zObjects:Array<FlxObject> = [];

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
        initParty();
    }

    function initParty()
    {
        for (memberID in 0...party.members.length)
        {
            var member = party.members[memberID];
            member.setPosition(startPos.x, startPos.y);
            add(member);
            if (member != party.leader)
                member.delay = memberID * 10;
            member.setGraphicSize(map.tileWidth, map.tileWidth * 2);
            member.updateHitbox();
            // Fix the hitbox after updating it
            member.adjustedHitbox = true;
            zObjects.push(member);
        }
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
                    adjustedData.push(id > 0 ? id - 1 : 0);
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
                }else
                    add(tilemap);
            }else{
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
                    }else{
                        if (objLayer.name.startsWith('_COLLIDERS'))
                        {
                            for (obj in objLayer.objects){
                                var collider = new FlxObject(obj.x, obj.y, obj.width, obj.height);
                                collider.immovable = true;
                                colliders.push(collider);
                            }
                        }else{
                            if (objLayer.name.startsWith('_SPAWN'))
                            {
                                for (obj in objLayer.objects)
                                    startPos = new FlxPoint(obj.x, obj.y);
                            }
                        }
                    }
                }
            }
        }
        for (zLayer in zLayers)
        {
            if (zLayer.layer == null || zLayer.objLayer == null){
                trace('ZLayer ' + zLayer.id + ' has no layer or object layer to pair with it. This layer will fail to load and become invisible.');
                continue;
            }
            for (obj in zLayer.objLayer.objects){
                var poly = obj.points;
                var tileLayer = zLayer.layer;
                var x = tileLayer.x;
                var y = tileLayer.y;
                var tileSize = tileLayer.tileWidth;
                var polygon = poly.map(p -> new FlxPoint(p.x + obj.x, p.y + obj.y));
                var zGroup = ZLayerBuilder.buildZLayerGroup(polygon, tileLayer, '$path/' + map.getTileSet(room.split('/')[1]).imageSource, tileSize, x, y);
                zObjects.push(zGroup);
                add(zGroup);
            }
        }
    }

    //-----Update-----//

    override public function update(elapsed:Float) {
        super.update(elapsed);
        for (member in party.members){
            if (member != party.leader)
                member.targetTrail.push(new FlxPoint(party.leader.x, party.leader.y));
            else{
                movement();
                collision();
            }
        }
        // z layering
        zObjects.sort(function(a:FlxObject, b:FlxObject):Int {
            return FlxSort.byY(FlxSort.ASCENDING, a, b);
        });
    }


    var runHeldFrames:Int = 0;

    function movement() {
        var leader = party.leader;
        var isRunning = FlxG.keys.pressed.SHIFT;
        var baseSpeed = 6;
        var speed = baseSpeed;

        if (isRunning) {
            runHeldFrames++;
            if (runHeldFrames >= 60) {
                speed += 6;
            } else if (runHeldFrames >= 10) {
                speed += 4;
            } else {
                speed += 2;
            }
        } else {
            runHeldFrames = 0;
        }

        var moveX = 0;
        var moveY = 0;

        if (FlxG.keys.pressed.RIGHT) moveX += 1;
        if (FlxG.keys.pressed.LEFT) moveX -= 1;
        if (FlxG.keys.pressed.DOWN) moveY += 1;
        if (FlxG.keys.pressed.UP) moveY -= 1;

        if (moveX != 0 && moveY != 0) {
            var norm = Math.sqrt(0.5); // approx 0.7071
            moveX = cast moveX * norm;
            moveY = cast moveX * norm;
        }
        
        // I need to move the collision rect instead of the base x y cause the main char is only visual. it follows its collision rect
        leader.x += moveX * (speed/4);
        leader.y += moveY * (speed/4);
    }


    // very simple. deltarune collisions are actually super simple.
    function collision() {
        for (collider in colliders)
            FlxG.collide(party.leader, collider);
    }
}