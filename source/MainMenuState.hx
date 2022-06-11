package;

import flixel.group.FlxSpriteGroup;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var vsTescoVersion:String = '3.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var debugKeys:Array<FlxKey>;

	var tescoLogo:FlxSprite;
	var youtubeButton:FlxSprite;
	var twitterButton:FlxSprite;

	var storyModeItems:Array<ItemData> = [];

	var itemData:Array<ItemData> = [];
	var items:FlxTypedGroup<TescoItem>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		var grayBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFF6F6F6);
		add(grayBG);

		tescoLogo = new FlxSprite(15, 15).loadGraphic(Paths.image('tescoAssets/MainMenu/MenuTesco'));
		tescoLogo.antialiasing = ClientPrefs.globalAntialiasing;
		tescoLogo.scale.set(0.6, 0.6);
		tescoLogo.updateHitbox();
		add(tescoLogo);

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

		itemData = [
			{
				itemName: "bred",
				itemWeight: "0.01",
				itemPrice: 1.51
			},
			{
				itemName: "spaghoti",
				itemWeight: "27000",
				itemPrice: -1.01
			},
			{
				itemName: "bolas",
				itemWeight: "50",
				itemPrice: 72.81
			},
			{
				itemName: "egg",
				itemWeight: "90",
				itemPrice: 127.85
			},
			{
				itemName: "oreo",
				itemWeight: "-10000",
				itemPrice: 69.47
			},
			{
				itemName: "foot lettuce",
				itemWeight: "15000",
				itemPrice: 15.15
			}
		];

		items = new FlxTypedGroup<TescoItem>();
		add(items);

		randomItem = itemData[FlxG.random.int(0, itemData.length - 1)];
		generateItems();

		var sideBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tescoAssets/CampaignMenu/CM_SideBar'));
		sideBar.scale.set(0.67, 0.67);
		sideBar.updateHitbox();
		sideBar.x = FlxG.width - sideBar.width;
		add(sideBar);

		// Play da funny menu music
		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			FlxG.sound.playMusic(Paths.music("freakyMenu"), 1);

		super.create();
	}

	var randomItem:ItemData;

	var isStoryMode:Bool = false;

	function generateItems()
	{
		// delete old items
		items.forEachAlive(function(i:TescoItem) {
			items.remove(i);
			i.kill();
			i.destroy();
		});

		if(isStoryMode)
		{
			var i:Int = 0;
			for(item in storyModeItems)
			{
				var newItem:TescoItem = new TescoItem(15, (tescoLogo.y + 57) + (i * 50), item.itemName, item.itemWeight, item.itemPrice);
				items.add(newItem);
				i++;
			}
		}
		else
		{
			var newItem:TescoItem = new TescoItem(15, (tescoLogo.y + 57), randomItem.itemName, randomItem.itemWeight, randomItem.itemPrice);
			items.add(newItem);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if(FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if(controls.BACK)
			MusicBeatState.switchState(new TitleState());

		super.update(elapsed);
	}
}

typedef ItemData = {
	var itemName:String;
	var itemWeight:String;
	var itemPrice:Float;
};

class TescoItem extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var icon:FlxSprite;

	public var nameTxt:FlxText;
	public var weightTxt:FlxText;
	public var priceTxt:FlxText;

	public var itemName:String;
	public var itemWeight:String;
	public var itemPrice:Float;

	public function new(x:Float, y:Float, itemName:String, itemWeight:String, itemPrice:Float)
	{
		super(x, y);

		this.itemName = itemName;
		this.itemWeight = itemWeight;
		this.itemPrice = itemPrice;

		// 1000G == 1KG

		bg = new FlxSprite().loadGraphic(Paths.image('tescoAssets/CampaignMenu/CM_ItemBox'));
		bg.scale.set(0.655, 0.67);
		bg.updateHitbox();
		add(bg);

		icon = new FlxSprite(15, 15).loadGraphic(Paths.image('tescoAssets/CampaignMenu/items/$itemName'));
		icon.antialiasing = ClientPrefs.globalAntialiasing;
		icon.setGraphicSize(Std.int(bg.height - 25), Std.int(bg.height - 25));
		icon.updateHitbox();
		add(icon);

		nameTxt = new FlxText(icon.x + (icon.width + 15), 15, 0, itemName, 32);
		nameTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF2b2b2b, LEFT);
		nameTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(nameTxt);

		var displayWeight:Float = Std.parseFloat(itemWeight);
		var thingie:String = "G";
		if(Math.abs(Std.parseFloat(itemWeight)) >= 1000)
		{
			if(displayWeight != 0)
				displayWeight /= 1000;

			thingie = "KG";
		}

		weightTxt = new FlxText(icon.x + (icon.width + 15), 50, 0, displayWeight + thingie, 32);
		weightTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF2b2b2b, LEFT);
		weightTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(weightTxt);

		priceTxt = new FlxText(0, 15, 0, "£" + itemPrice, 32);
		priceTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF2b2b2b, LEFT);
		priceTxt.antialiasing = ClientPrefs.globalAntialiasing;
		priceTxt.x = bg.width - (priceTxt.width + 15);
		add(priceTxt);
	}
}
