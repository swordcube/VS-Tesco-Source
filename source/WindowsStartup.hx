package;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;

class WindowsStartup extends MusicBeatState
{
    public var windows7:FlxSprite;
    public var bg:FlxSprite;

    override public function create()
    {
        super.create();

        persistentUpdate = true;
        persistentDraw = true;

        FlxG.mouse.visible = false;

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        trace("haha this is gonna take up alot of memory isn't it");

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF567cb0);
        bg.visible = false;
        add(bg);

        windows7 = new FlxSprite();
        windows7.frames = Paths.getSparrowAtlas('win7/boot');
        windows7.animation.addByPrefix('a', 'windowSeven', 20, false);
        windows7.animation.play('a', true);
        windows7.antialiasing = ClientPrefs.globalAntialiasing;
        windows7.scale.set(1.5, 1.5);
        windows7.updateHitbox();
        windows7.screenCenter();
        add(windows7);
    }

    var booted:Bool = false;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(!booted && windows7 != null && windows7.animation.curAnim.finished)
        {
            booted = true;
            remove(windows7);
            windows7.kill();
            windows7.destroy();
            windows7 = null;

            new FlxTimer().start(1, function(tmr:FlxTimer) {
                bg.visible = true;
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    FlxG.switchState(new TitleState());
                });
            });
        }
    }
}