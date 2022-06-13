package staffID;

import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class StaffIDMenu extends MusicBeatSubstate
{
    var numbers:Array<FlxSprite> = [];

    var back:FlxSprite;
    var accept:FlxSprite;

    var text:FlxText;

    override public function create()
    {
        super.create();
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.5;
        add(bg);

        var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tescoAssets/StaffID/SID_Box'));
        box.antialiasing = ClientPrefs.globalAntialiasing;
        box.scale.set(0.67, 0.67);
        box.updateHitbox();
        box.screenCenter();
        add(box);

        var wahh:FlxSprite = new FlxSprite(0, box.y + 30).loadGraphic(Paths.image('tescoAssets/StaffID/SID_EnterText'));
        wahh.antialiasing = ClientPrefs.globalAntialiasing;
        wahh.scale.set(0.67, 0.67);
        wahh.updateHitbox();
        wahh.screenCenter(X);
        add(wahh);

        var wahh:FlxSprite = new FlxSprite(0, box.y + 130).loadGraphic(Paths.image('tescoAssets/StaffID/SID_Line'));
        //wahh.antialiasing = ClientPrefs.globalAntialiasing;
        wahh.scale.set(0.67, 0.67);
        wahh.updateHitbox();
        wahh.screenCenter(X);
        add(wahh);

        text = new FlxText(0, wahh.y - 60, 0, "", 32);
        text.antialiasing = ClientPrefs.globalAntialiasing;
        text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.BLACK, CENTER);
        text.screenCenter(X);
        add(text);

        var rows:Int = 0;
        var cock:Int = 0;
        var i:Int = 1;
        for(j in 1...10)
        {
            var n:FlxSprite = new FlxSprite((box.x + 70) + (cock * 110), (wahh.y + 40) + (rows * 80)).loadGraphic(Paths.image('tescoAssets/StaffID/SID_${i}'));
            n.antialiasing = ClientPrefs.globalAntialiasing;
            n.scale.set(0.67, 0.67);
            n.updateHitbox();
            n.ID = i;
            numbers.push(n);
            add(n);
            i++;
            cock++;
            if(cock % 3 == 0)
            {
                rows++;
                cock = 0;
            }
        }
        var n:FlxSprite = new FlxSprite(numbers[1].x, (wahh.y + 40) + (rows * 80)).loadGraphic(Paths.image('tescoAssets/StaffID/SID_0'));
        n.antialiasing = ClientPrefs.globalAntialiasing;
        n.scale.set(0.67, 0.67);
        n.updateHitbox();
        n.ID = i;
        numbers.push(n);
        add(n);

        back = new FlxSprite(numbers[0].x, numbers[numbers.length - 1].y).loadGraphic(Paths.image('tescoAssets/StaffID/SID_Back'));
        back.antialiasing = ClientPrefs.globalAntialiasing;
        back.scale.set(0.67, 0.67);
        back.updateHitbox();
        add(back);

        accept = new FlxSprite(numbers[numbers.length - 1].x + 110, numbers[numbers.length - 1].y).loadGraphic(Paths.image('tescoAssets/StaffID/SID_Accept'));
        accept.antialiasing = ClientPrefs.globalAntialiasing;
        accept.scale.set(0.67, 0.67);
        accept.updateHitbox();
        add(accept);

        FlxG.sound.muteKeys = [];
    }

    var numKeys:Array<Array<FlxKey>> = [
        [ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, ZERO],
        [NUMPADONE, NUMPADTWO, NUMPADTHREE, NUMPADFOUR, NUMPADFIVE, NUMPADSIX, NUMPADSEVEN, NUMPADEIGHT, NUMPADNINE, NUMPADZERO]
    ];

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.sound.muteKeys = TitleState.muteKeys;
            MainMenuState.instance.inStaffID = false;
            close();
        }

        for(thing in numKeys)
        {
            var i:Int = 0;
            for(key in thing)
            {
                if(FlxG.keys.checkStatus(key, JUST_PRESSED))
                {
                    if(text.text.length < 4)
                    {
                        if(key == ZERO || key == NUMPADZERO)
                        {
                            text.text += "0";
                            text.screenCenter(X);
                        }
                        else
                        {
                            text.text += Std.string(i+1);
                            text.screenCenter(X);
                        }
                    }
                }
                i++;
            }
        }

        for(num in numbers)
        {
            switch(num.ID)
            {
                case 10:
                    if(text.text.length < 4 && isObjectClicked(num))
                    {
                        trace("NUMBER ZERO INPUTTED!");
                        text.text += "0";
                        text.screenCenter(X);
                    }
                default:
                    if(text.text.length < 4 && isObjectClicked(num))
                    {
                        trace("ANY OTHER NUMBER INPUTTED!");
                        text.text += Std.string(num.ID);
                        text.screenCenter(X);
                    }
            }
        }
        
        if(FlxG.keys.justPressed.BACKSPACE || isObjectClicked(back))
        {
            text.text = text.text.substring(0, text.text.length - 1);
            text.screenCenter(X);
        }

        if(controls.ACCEPT || isObjectClicked(accept))
        {
            switch(text.text)
            {
                case "1234":
                    PlayState.storyWeek = 1;
                    PlayState.SONG = Song.loadFromJson('bopeebo-hard', 'bopeebo');
                    LoadingState.loadAndSwitchState(new PlayState());
            }

            text.text = "";
            text.screenCenter(X);
        }
    }

	function isObjectClicked(object:FlxBasic)
	{
		if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(object))
			return true;

		return false;
	}
}