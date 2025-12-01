# Nutrilusion
## Preamble
This app was built for me to learn the flow of an iOS developer, but I also made it because I thought it would be fun to make my own free nutrition tool to track my daily nutrition intake (mostly calories...). I plan on continuing its development in the future whenever I have time because I still plan on using it myself. I tried to make it as configurable as possible. Most of the nutrient-centric information is configurable so you can easily add localizations for nutrition items so the OCR system can do multiple languages. The app itself has no localizations for text because I'd only ever use the app in English and I have no plans on marketing the app elsewhere.

## The App
You can log foods to the timeline and see them take up visual space while also being tallied towards the hourly and daily nutrient intake.
![Timeline screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appFullHomescreen.png "Timeline screenshot with multiple logged items.")

You can press the "+ @ (Time)" button to open the creation/editing mode for logged items. You'll need to choose an existing recipe or create a transient recipe that'll only be used this once (maybe you went to a restaurant and only care to quickly log the calories).
![Empty new log menu screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appLogNewItemEmpty.png "Log menu with nothing yet chosen.")

Pressing "Choose Recipe" brings up all the available recipe listings. You can also: create categories, create new recipes, search for recipes, and edit existing recipes on this screen. The first three options have obvious buttons at the bottom right, but the last option can be done by pressing the expand button on a recipe (V), and then the pencil icon that takes its place at the bottom right.
Base View             |  Expanded Food Item Details
:-------------------------:|:-------------------------:
![Recipe list screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appRecipeListFull.png "Recipe list with nothing expanded.")  |  ![Recipe list screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appFoodItemDetails.png "Recipe list with smoothie expanded to show details.")

When you edit a food item, you can change the name, the units, the base serving amount, and the ingredient(s), and nutrient(s) associated with it. The ingredient and nutrient views are seperate. The nutrient view allows you to enable (and disable) a mode that will propagate changes to child nutrients to the parents. For example, if Omega-6 increases by 6g, with this option active, the "Fats" category will go up by the same amount. This is pretty helpful if you're creating a food from complete scratch, but most people are just going to read a nutrition label and copy it line by line, so this option is off by default. There is a third mode that makes copying nutrition labels easier: Camera mode. It requires you to allow access to the camera, and when you point the viewfinder at a nutrition label, the app will do its best to copy that over to the app for you to modify it. It doesn't work very well in darker settings or with shiny labels, but in my experience it was somewhat decent and it definitely always made it easier to copy over the information, even if it did get a couple of the values wrong.
Ingredient             |  Nutrient
:-------------------------:|:-------------------------:
![Food item ingredient editing screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appIngredientEdit.png "Ingredient editing mode for a food item.")  |  ![Food item nutrient editing screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appNutrientEdit.png "Nutrient editing mode for a food item.")

When you tap a food item, you'll be taken back to the logging menu you started with the finalize the serving size, time to log, and the nutrients you think are most important at first glance:
![Log menu screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appLogNewItem.png "Log menu with a smoothie food item chosen.")

Most of the images above were in light-mode, but dark-mode is fully supported and I think it looks even better in darkmode:
![Dark mode timeline screenshot](https://github.com/andrziv/Nutrilusion-Client/blob/main/readmeImages/appFullHomescreenDarkModified.png "Timeline screenshot with multiple logged items in dark mode.")

## How to Install
I recommend using an iPhone for this app, it runs on iPads but it just wasn't designed with them in mind. This app should look as designed on modern 6+ inch screen size iPhones (Basic, Air, Pro, Pro Max)

I unfortunately do not have an Apple Developer account, so you can't easily install this off the appstore. Fortunately, it's pretty easy to get it to run if you have a Mac:
1. Clone the repo and open Xcode against the cloned project file (.xcodeproj)
2. Connect your device to Xcode. I suggest following Apple's own [documentation](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device) for this bit, but I'll summarize the key steps here:
    - First set of steps:
        - Make sure the Mac and iOS device are on the same Wi-Fi network
        - Connect the device to you mac with a physical connection (USB cable)
        - On the Mac toolbar, go to Window > Devices and Simulators, and connect your iOS device
            - Select the device from the list in the Devices and Simulators window in Xcode and click the pairing button which triggers a code to appear on the target device.
        - Enter the code on the Mac to complete the pairing process
    - You should be able to install the app by changing the run configuration to your mobile device. Apple recommends following a second set of steps before installing the app, though:
        - Mac toolbar: Xcode (make sure Xcode is the focused window) > Settings > Apple Accounts > Add Apple Account (the account you want to use for signing)
        - In the Xcode File Tree, open the Project Settings by clicking on the top-level project file > [Targets] Swiftui-Nutrilusion > Code and Signing Capabilities > Choose a valid team
        - [Optional] Register the device with your team if you belong to the [Apple Developer Program](https://developer.apple.com/programs/).
        - Enable Developer Mode on your iOS device
3. Note that this app requires Camera capabilities, so just add "Privacy - Camera Usage Description" under Info in the Project Settings if it wasn't already there
4. You should be able to run the app now. Note that you'll need to reconnect your device to the Mac every so often to rerun the app build to keep it signed. It is every:
    - 7 days for basic Apple accounts, or
    - 365 days if you have an Apple Developer account

## Future Plans
### Client
1. Fix the keyboard interaction in the ingredient/nutrient editors where the keyboard blocks the textfields.
2. Have default "important nutrients" auto-selected when a food item is selected to be logged.
3. Improve the nutrient icons so they're more clear in purpose
4. Implement a colour brightness algorithm to adjust the text colours so text is still readable, even if it's lightmode with yellow backgrounds.
    - https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
    - https://gist.github.com/mnpenner/70ab4f0836bbee548c71947021f93607
5. Implement the monthly stat graphs and weight trackers.
6. Optimize the App so it doesn't load absolutely everything all at once, and only when things are needed.
7. Extend the timeline view so it shows more than the current week. I want to target a period of a full year before logged items should get culled.
8. Optionally interact with a server if one is currently active.
    8a. Implement device profiles so someone can potentially load their logged items if they previously connected to a server and deleted the app.
9. Implement settings so users can better configure their experience.
10. Implement a startup tutorial so users aren't thrown into the deep-end on startup.
11. Far future: Potentially implement food recommendation algorithms to find the foods that best fulfil a user's leftover needs?
12. Very far future: Potentially implement nutrient planning algorithms to improve diets?

### Server
The plan is for it to be a Java-Spring-Hibernate-Postgres server, but the database isn't locked-in.
- The server needs to be able to handle version conflicts (i.e. user 1 makes an edit to Ham Sandwich v2, at the same time that user 2 makes an edit to Ham Sandwich v2)
    - Probably implement subversions that are custom to users and just provide the first one to anyone else as a default
    - This also goes for users who never connected after the first connection and have a slew of conflicting versions used in multiple spots as ingredients
- Shouldn't ever cull "unused" Foods
- Should log which users deleted what so it's never shown to them again
- Sanitize inputs
