package frontend.mods;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import lime.app.Application;
import backend.game.*;

//TODO: properly documment
class ChapterSelect extends FlxState
{
    // Configuration variables
    var chapters:Array<String> = Asset.readDirectory('mods');
    var itemHeight:Float;
    var innerSpace:Float = 16;
    var textHeight:Float;
    var topY:Float = 64;
    var bottomY:Float;
    var centerY:Float;
    var visibleHeight:Float;
    var iconX:Float = FlxG.width - 100;

    // Menu elements
    var chapterLabels:Array<DeltaText> = [];
    var chapterTitles:Array<DeltaText> = [];
    var chapterIcons:Array<FlxSprite> = [];
    var separators:Array<FlxSprite> = [];
    var datas:Array<backend.mods.Mod.ModInfo>=[];

    var selector:FlxSprite;
    var quitText:DeltaText;
    var bottomIndicator:FlxSprite;
    var play:DeltaText;
    var confirmOrNot:DeltaText;
    var bottomBox:FlxSprite;
    var offset(default, set):Float = 0;
    var targetOffset:Float = 0;
    var idx:Int = 0;
    var minOffset:Float;
    var confirmMode:Bool = false;
    var confirmChoice:Bool = true;
    override public function create():Void
    {
        super.create();

        FlxG.mouse.visible = false;

        bottomY = FlxG.height - 100;
        centerY = FlxG.height / 2;
        visibleHeight = bottomY - topY;

        sortChapters();
        final tSize = 1;
        final letterSpace = -1;

        var dummy = createDeltaText("Dummy", LEFT, -1000, -1000, tSize, letterSpace, false);
        textHeight = dummy.height;
        remove(dummy);

        itemHeight = textHeight + 2 * innerSpace + 2;

        for (i in 0...chapters.length)
        {
            final jsonData = Asset.loadJSON('mods/${chapters[i]}/data');
            datas.push(jsonData);
            var slotY:Float = topY + i * itemHeight;
            var textY:Float = slotY + innerSpace;
            var sepY:Float = textY + textHeight + innerSpace;
            var chapterLabel = createDeltaText(
                'Chapter ${(jsonData.chapterSelect.chapterNum != null) ? jsonData.chapterSelect.chapterNum : '?'}', 
                CENTER, 0, textY, tSize, letterSpace);
            chapterLabel.updateHitbox();
            chapterLabel.screenCenter(X);
            chapterLabel.x -= 64 * 3;
            chapterLabels.push(chapterLabel);

            var chapterTitle = createDeltaText(
                '${(jsonData.chapterSelect.chapterNum != null) ? jsonData.chapterSelect.chapterTitle : '--'}', 
                CENTER, 0, textY, tSize, letterSpace);
            chapterTitle.updateHitbox();
            chapterTitle.screenCenter(X);
            chapterTitle.x += 64;
            chapterTitles.push(chapterTitle);

            var icon = new FlxSprite(iconX, textY);
            if(jsonData.chapterSelect.iconName == null)icon.makeGraphic(32, 32, 0xFFAAAAAA);
            else {
                icon.loadGraphic(Asset.outSourcedImage('mods/${chapters[i]}/ChapterSelect/${jsonData.chapterSelect.iconName}'));
                icon.scale.set(2, 2);
            }
            add(icon);
            chapterIcons.push(icon);

            var separator = new FlxSprite(0, sepY);
            separator.makeGraphic(FlxG.width + 2, 2, 0xFF2c2c2c);
            add(separator);
            separators.push(separator);
        }

        play = createDeltaText("Play", LEFT, 0, 0, tSize, letterSpace);
        play.visible = false;

        confirmOrNot = createDeltaText("Or Not", LEFT, 0, 0, tSize, letterSpace);
        confirmOrNot.visible = false;

        bottomBox = new FlxSprite(0, FlxG.height - 64);
        bottomBox.makeGraphic(FlxG.width, 64, 0xFF000000);
        add(bottomBox);

        quitText = createDeltaText("Quit", CENTER, 0, FlxG.height - 80, tSize, letterSpace);
        quitText.updateHitbox();
        quitText.screenCenter(X);
        quitText.y = FlxG.height - quitText.height - 16;

        var copyright = createDeltaText('FlxDeltarune V.${Application.current.meta.get('version')}\nNOT afilliated with Toby Fox.', LEFT, 0, 0, 0.5, letterSpace);
        copyright.alpha = 0.5;
        copyright.updateHitbox();
        copyright.y = FlxG.height - copyright.height;
        copyright.x += 16;
        copyright.y -= 16;

        bottomIndicator = new FlxSprite(FlxG.width / 2 - 10, bottomY + 10);
        bottomIndicator.loadGraphic(Asset.image('ui/arrow'));
        add(bottomIndicator);
        bottomIndicator.visible = false;
        FlxTween.tween(bottomIndicator, {y: bottomIndicator.y - 4}, 0.5, {type: PINGPONG, ease: FlxEase.sineInOut});

        var totalHeight:Float = chapters.length * itemHeight;
        minOffset = visibleHeight - totalHeight + 64;
        if (minOffset > 0) minOffset = 0;

        selector = new FlxSprite(0, topY);
        selector.loadGraphic(Asset.image('battle/soul'));
        add(selector);

        FlxG.sound.playMusic(Asset.sound('music/AUDIO_DRONE.ogg'));

        FlxG.camera.y += 64;
        introTwn = FlxTween.tween(FlxG.camera, {y: 0}, 1, {ease: FlxEase.quadOut});
        FlxG.camera.fade(flixel.util.FlxColor.BLACK, 1, true, ()->allow=true);

        updateSelection();
        allow=false;
    }

    var introTwn:FlxTween;
    private function createDeltaText(text:String, alignment:flixel.text.FlxText.FlxTextAlign, x:Float = 0, y:Float = 0, scale:Float = 1, letterSpacing:Int = -1, addIt:Bool = true):DeltaText
    {
        var dt = new DeltaText();
        dt.text = text;
        dt.alignment = alignment;
        dt.scale.set(scale, scale);
        dt.letterSpacing = letterSpacing;
        dt.setPosition(x, y);
        if (addIt) add(dt);
        return dt;
    }

    private function sortChapters():Void
    {
        var allNumeric:Bool = true;
        var nums:Array<Float> = [];
        for (c in chapters)
        {
            var n = Std.parseFloat(c);
            if (Math.isNaN(n)) allNumeric = false;
            nums.push(n);
        }

        var paired:Array<{id:String, num:Float}> = [for (i in 0...chapters.length) {id: chapters[i], num: nums[i]}];

        if (allNumeric)
            paired.sort(function(a, b) return (a.num < b.num) ? -1 : (a.num > b.num) ? 1 : 0);
        else
            paired.sort(function(a, b) return (a.id < b.id) ? -1 : (a.id > b.id) ? 1 : 0);

        chapters = [for (p in paired) p.id];
    }

    var allow:Bool = true;
    var scales:flixel.math.FlxPoint = flixel.math.FlxPoint.get(1, 1);
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if(!allow) return;

        if(!confirmMode)
        {
            if (FlxG.keys.justPressed.DOWN)
                changeSelection(1);
            else if (FlxG.keys.justPressed.UP)
                changeSelection(-1);
        }

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
        {
            if (confirmMode)
            {
                FlxG.sound.play(Asset.sound('sounds/player/menumove.wav'));
                confirmChoice = !confirmChoice;
                updateSelection();
            }
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            FlxG.sound.play(Asset.sound('sounds/player/select.wav'));
            if (confirmMode)
            {
                if (confirmChoice)
                {
                    allow = false;

                    // I REALLY think it's impossible to break the tween before it finishes
                    // but still, better to prevent it from happening anyways...
                    if(introTwn != null && introTwn.active) introTwn.cancel();

                    FlxG.sound.music.stop();
                    FlxG.sound.play(Asset.outSourcedSound('mods/${chapters[idx]}/ChapterSelect/${datas[idx].chapterSelect.onSelectSFX}'));
                    Logger.info("Chapter selected from mod " + chapters[idx]);
                    FlxTween.tween(scales, {x: 0.3, y: 1}, 1, {onUpdate: (_) -> FlxG.camera.setScale(scales.x, scales.y)});
                    FlxTween.tween(FlxG.camera, {y:-150}, 1);
                    FlxG.camera.fade(flixel.util.FlxColor.BLACK, 1, false, () -> {
                        curMod = new backend.mods.Mod(datas[idx]);
                        //trace(curMod.info);
                        //trace(datas[idx]);

                        //TODO: save system to detect the first time playing tuff
                        Logger.info('FIRST TIME PLAYING THE MOD! Redirecting to IntroState...');

                        new flixel.util.FlxTimer().start(2, _-> FlxG.switchState(()-> new frontend.mods.IntroState()));
                    });
                }
                else
                {
                    confirmMode = false;
                    updateSelection();
                }
            }
            else
            {
                if (idx < chapters.length)
                {
                    confirmMode = true;
                    confirmChoice = true;
                    updateSelection();
                }
                else
                {
                    // TODO: Quit action
                    Logger.info('Quitting...');
                }
            }
        }

        offset = FlxMath.lerp(offset, targetOffset, elapsed * 12);
        if (Math.abs(offset - targetOffset) < 0.1)
            offset = targetOffset;
        bottomIndicator.visible = (offset > minOffset);
    }

    function changeSelection(change:Int = 0):Void
    {
        idx = FlxMath.wrap(idx + change, 0, chapters.length);
        FlxG.sound.play(Asset.sound('sounds/player/menumove.wav'));
        updateSelection();
    }

    private function updateSelection():Void
    {
        // Reset colors and visibilities
        for (i in 0...chapterLabels.length)
        {
            chapterLabels[i].color = 0xFFFFFFFF;
            chapterTitles[i].color = 0xFFFFFFFF;
            chapterIcons[i].color = 0xFFFFFFFF;
            chapterTitles[i].visible = true;
        }
        quitText.color = 0xFFFFFFFF;
        play.visible = false;
        confirmOrNot.visible = false;

        if (idx < chapters.length)
        {
            chapterLabels[idx].color = 0xFFFFFF00;
            chapterIcons[idx].color = 0xFFFFFF00;
            if (!confirmMode)
                chapterTitles[idx].color = 0xFFFFFF00;

            selector.visible = true;
            selector.y = chapterLabels[idx].y + chapterLabels[idx].height / 2 - selector.height / 2;
            final itemCenterOffset:Float = itemHeight / 2;

            targetOffset = (centerY - itemCenterOffset) - topY - (idx * itemHeight);
            if (targetOffset > 0) targetOffset = 0;
            if (targetOffset < minOffset) targetOffset = minOffset;

            if (idx == chapters.length - 1)
            {
                var projected_slot_y = topY + (chapters.length - 1) * itemHeight + targetOffset;
                var projected_text_y = projected_slot_y + innerSpace;
                var projected_sep_y = projected_text_y + textHeight + innerSpace;
                var projected_sep_bottom = projected_sep_y + 2;
                if (projected_sep_bottom > bottomY)
                {
                    var excess = projected_sep_bottom - bottomY;
                    targetOffset -= excess;
                }
            }

            if (confirmMode)
            {
                chapterTitles[idx].visible = false;
                play.visible = true;
                play.color = confirmChoice ? 0xFFFFFF00 : 0xFFFFFFFF;
                confirmOrNot.visible = true;
                confirmOrNot.color = !confirmChoice ? 0xFFFFFF00 : 0xFFFFFFFF;
            }
        }
        else
        {
            quitText.color = 0xFFFFFF00;
            selector.visible = true;
            selector.y = quitText.y + quitText.height / 2 - selector.height / 2;
        }

        positionItems();
    }

    private function positionItems():Void
    {
        for (i in 0...chapters.length)
        {
            final slotY = topY + (i * itemHeight) + offset;
            final textY = slotY + innerSpace;
            chapterLabels[i].y = textY;
            chapterTitles[i].y = textY;
            chapterIcons[i].y = textY;
            separators[i].y = textY + textHeight + innerSpace;
        }
        if (idx < chapters.length)
        {
            if(!confirmMode) selector.x = chapterLabels[idx].x - selector.width - 16;
            selector.y = chapterLabels[idx].y + chapterLabels[idx].height / 2 - selector.height / 2;
            if (confirmMode)
            {
                play.x = chapterTitles[idx].x;
                play.y = chapterTitles[idx].y;
                confirmOrNot.x = play.x + play.width + 64;
                confirmOrNot.y = chapterTitles[idx].y;

                final thing:DeltaText = ((confirmChoice)? play : confirmOrNot);
                selector.x = thing.x - selector.width - 8;
            }
        }
        else
        {
            selector.x = quitText.x - selector.width - 16;
            selector.y = quitText.y + quitText.height / 2 - selector.height / 2;
        }
    }

    @:noCompletion function set_offset(offset:Float):Float
    {
        this.offset = offset;
        positionItems();
        return offset;
    }
}