package;

import flixel.FlxBasic;
import flixel.text.FlxText;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.app.Application;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var startedAlready:Bool = false;

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	// tesco shit
	var playButton:FlxSprite;
	var ostButton:FlxSprite;
	var creditsButton:FlxSprite;

	var funFact:FlxSprite;

	var youtubeButton:FlxSprite;
	var twitterButton:FlxSprite;

	var realText:FlxText;
	var theFuckingTescoDot:FlxText;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		#if CHECK_FOR_UPDATES
		if(!startedAlready) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/swordcube/VS-Tesco-Source/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.vsTescoVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		PlayerSettings.init();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		if(FlxG.save.data.photoSensitive == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			startedAlready = true;

			FlxG.mouse.visible = true;

			FlxG.mouse.load(Paths.image('windowCursor').bitmap.clone());

			// Play da funny menu music
			if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
				FlxG.sound.playMusic(Paths.music("freakyMenu"), 1);

			var grayBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF6F6F6);
			add(grayBG);

			var tescoLogo:FlxSprite = new FlxSprite(15, 15).loadGraphic(Paths.image('tescoAssets/MainMenu/MenuTesco'));
			tescoLogo.antialiasing = ClientPrefs.globalAntialiasing;
			tescoLogo.scale.set(0.6, 0.6);
			tescoLogo.updateHitbox();
			add(tescoLogo);

			var splashBox:FlxSprite = new FlxSprite(0, tescoLogo.y + 57).loadGraphic(Paths.image('tescoAssets/MainMenu/MM_SplashBox'));
			splashBox.scale.set(0.67, 0.67);
			splashBox.updateHitbox();
			splashBox.screenCenter(X);
			add(splashBox);

			var funnyTexts:Array<String> = [
				"Bread.",
				"Funky Tesco.",
				"Super Idol.",
				"heheheha!",
				"I love bags!!",
				"Brand spankin new!",
				"Are you gay?",
				"Every little helps.",
				"Clubcard Accepted.",
				"Clubcard DENIED.",
				"Do you want phone?",
				"FL Studio has died.",
				"OREO CREAM!",
				"bri\'ish??",
				"yellow teeth??",
				"walmar.",
				"asda.",
				"like and subscri be!",
				"unexpected ass.",
				"Adobe Laughter!",
				"WANT A BREAK FROM THE ADS?",
				"yootoob premum.",
				"how to friday fuckin!?",
				"*notices your-* NO.",
				"click this text for a cookie!",
				"ITS BLOMMIN £3.50 IM FUMIN!!",
				"upgrad to window 10.",
				"RTC Connecting...",
				"Kayne Central.",
				"osu!tesco",
				"you stinky.",
				"egg plant.",
				"exodussy."
			];

			var skipCharacters:Array<String> = [
				".",
				"!",
				"?",
			];

			var genText:String = funnyTexts[FlxG.random.int(0, funnyTexts.length - 1)];
			var arrayText:Array<String> = genText.split("");

			var dots:Array<String> = [];

			var char_i:Int = 0;
			for(c in skipCharacters)
			{
				// look ik this is probably a bad way of doing this
				// but i don't care lmao

				switch(genText)
				{
					case "ITS BLOMMIN £3.50 IM FUMIN!!":
						if(c != ".")
						{
							while(arrayText.contains(c))
							{
								arrayText.remove(c);
								dots.push(c);
							}
						}
					case "osu!tesco":
						if(c != "!")
						{
							while(arrayText.contains(c))
							{
								arrayText.remove(c);
								dots.push(c);
							}
						}
					default:
						while(arrayText.contains(c))
						{
							arrayText.remove(c);
							dots.push(c);
						}
				}
				char_i++;
			}

			realText = new FlxText(0, 0, 0, arrayText.join(""), 48);
			realText.setFormat(Paths.font("vcr.ttf"), 48, 0xFF00539F, CENTER);
			realText.antialiasing = ClientPrefs.globalAntialiasing;
			realText.y = (splashBox.y + (splashBox.height / 2)) - (realText.height / 2);
			realText.screenCenter(X);
			add(realText);

			theFuckingTescoDot = new FlxText(realText.x + (realText.width), 0, 0, dots.join(""), 48);
			theFuckingTescoDot.setFormat(Paths.font("vcr.ttf"), 48, 0xFFFF0000, CENTER);
			theFuckingTescoDot.antialiasing = ClientPrefs.globalAntialiasing;
			theFuckingTescoDot.y = realText.y;
			add(theFuckingTescoDot);

			realText.x -= dots.length * 10;
			theFuckingTescoDot.x -= dots.length * 10;

			var buttonMult:Float = 150;

			playButton = new FlxSprite().loadGraphic(Paths.image('tescoAssets/MainMenu/MM_PlayButton'));
			playButton.scale.set(0.65, 0.65);
			playButton.updateHitbox();
			playButton.screenCenter(X);
			playButton.x -= buttonMult;
			playButton.y = splashBox.y + (splashBox.height + 30);
			playButton.antialiasing = ClientPrefs.globalAntialiasing;
			add(playButton);

			ostButton = new FlxSprite().loadGraphic(Paths.image('tescoAssets/MainMenu/MM_OSTButton'));
			ostButton.scale.set(0.65, 0.65);
			ostButton.updateHitbox();
			ostButton.screenCenter(X);
			ostButton.x += buttonMult;
			ostButton.y = playButton.y;
			ostButton.antialiasing = ClientPrefs.globalAntialiasing;
			add(ostButton);

			funFact = new FlxSprite(0, ostButton.y + 80).loadGraphic(Paths.image('tescoAssets/MainMenu/MM_FUNFACT'));
			funFact.scale.set(0.6, 0.6);
			funFact.updateHitbox();
			funFact.screenCenter(X);
			funFact.antialiasing = ClientPrefs.globalAntialiasing;
			add(funFact);

			creditsButton = new FlxSprite(0, funFact.y + 50).loadGraphic(Paths.image('tescoAssets/MainMenu/MM_CreditsButton'));
			creditsButton.scale.set(0.6, 0.6);
			creditsButton.updateHitbox();
			creditsButton.screenCenter(X);
			creditsButton.antialiasing = ClientPrefs.globalAntialiasing;
			add(creditsButton);

			youtubeButton = new FlxSprite(15, 0).loadGraphic(Paths.image('tescoAssets/MainMenu/MenuYT'));
			youtubeButton.scale.set(0.7, 0.7);
			youtubeButton.updateHitbox();
			youtubeButton.y = FlxG.height - (youtubeButton.height + 15);
			youtubeButton.antialiasing = ClientPrefs.globalAntialiasing;
			add(youtubeButton);

			twitterButton = new FlxSprite(youtubeButton.x + (youtubeButton.width + 15), 0).loadGraphic(Paths.image('tescoAssets/MainMenu/MenuTWT'));
			twitterButton.scale.set(0.7, 0.7);
			twitterButton.updateHitbox();
			twitterButton.y = FlxG.height - (twitterButton.height + 15);
			twitterButton.antialiasing = ClientPrefs.globalAntialiasing;
			add(twitterButton);

			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		else
			Conductor.songPosition += FlxG.elapsed * 1000;

		super.update(elapsed);

		if(isObjectClicked(playButton))
			MusicBeatState.switchState(new MainMenuState());

		if(isObjectClicked(ostButton))
			CoolUtil.browserLoad("https://www.youtube.com/playlist?list=PLMn10BObyn_erICjEGQJXVUvbttbtEpN9");

		if(isObjectClicked(creditsButton))
			MusicBeatState.switchState(new CreditsState());

		if(isObjectClicked(youtubeButton))
			CoolUtil.browserLoad("https://www.youtube.com/c/JadynSmells");

		if(isObjectClicked(twitterButton))
			CoolUtil.browserLoad("https://twitter.com/vsTesco");

		// Obtain a free cookie!
		if(realText.text.contains("click this text for a cookie") && (isObjectClicked(realText) || isObjectClicked(theFuckingTescoDot)))
			CoolUtil.browserLoad("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
	}

	function isObjectClicked(object:FlxBasic)
	{
		if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(object))
			return true;

		return false;
	}
}
