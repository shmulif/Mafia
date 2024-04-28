**Mafia game for iOS**

Before working on this it is important to be familiar with the rules of Mafia. You can check out this Wikipedia article https://en.wikipedia.org/wiki/Mafia_(party_game)


**Description:**

The app is designed so that everyone can join from their own phone. The software assigns random roles to everyone (At the moment it is designed for six players). The app gives abilities or information to the players depending on their role. For example, the mafias have the ability to eliminate someone and the detective is given someone's
identity. The game will run through night and day cycles. During the night the mafia will communicate with a private chat between them and everyone with abilities will be given the opportunity to use them. In the day there will be a chat with all players, The mafia cannot communicate privately during the day. If someone was eliminated they cannot participate in the chat. The game tracks who wins based on the rules of Mafia.


**Setup Instructions:**

Like all iOS development, it must be done on a Mac.
1) Open Xcode (If you don't have it yet, download it from the Mac app store).
2) Select "Clone Git Repository".
4) Paste the URL for this repository into the search bar that appears at the top.
5) Hit "clone".
3) Select a location to save it.
The files are now on your computer, however, for the app to run you must incorporate Firebase. Instructions are provided in the next section.


**Incorporating Firebase:**

You will need to set up a Firebase account and incorporate it into your project, This video provides a detailed guide https://www.youtube.com/watch?v=sHWX5j6wUjA You can skip the last step in the video of adding the configuration code (at 16:50) because the code is already added to the project.
(Check out the rest of that channel for help with iOS development in general including more help with using Firebase in Swift.)

**Enable Authentication and Firestore:**
Once your Firebase account is set up you must enable Firestore and Authentication. They can both be found in the left panel of your Firbase console. Under Firestore click 'Create database' to enable it. Under 'Authentication' click 'get started', select 'Anonymous', and  click 'enable'.

**Firestore Security:**

If your contributions to this project will be open source, it is best not to share the file called "GoogleService-Info.plist" (this file was downloaded during the setup of Firebase). This is the easiest way to ensure that no unwanted users can access your database. The repo already has a gitignore which will exclude the file.

If you plan on publishing the app then the information in that file will be publicly available, so you will need to set up more advanced security measures. This video is a good guide for setting up security rules https://www.youtube.com/watch?v=ysvmtLCYou0 Documentation on Firetore security rules can be found here https://firebase.google.com/docs/rules  Additionally, it is recommended to set up a Firebase service called "App check". This is a paid service that ensures that your database can only be accessed from users of your app. Its documentation can be found here https://firebase.google.com/docs/app-check

**Some Ideas for Additions:**
1) Have the app work for a custom amount of players (Minimum should be four, one Mafifa, one Detective, one Doctor, one Civilian).
2) Have specialty roles that players can choose to include. There are some great ideas in the Wikipedia article above, as well as at this link https://deusexmafia.fandom.com/wiki/Mafia_Roles
3) Add an overview of the rules.
4) Create variations of the game that fit in different genres or time-periods. For example, there can be a werewolf variation or a world war II spy variation.

If you have a suggested addition I would love to hear about it! Please post it under issues and label it 'enhancement'.
