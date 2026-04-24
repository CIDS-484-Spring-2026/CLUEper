# CLUEper

CAPSTONE PROJECT - CIDS484
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

CLUEper – A Digital Notecard Companion for the Board Game Clue
Project Description
CLUEper is an iOS mobile application idea I have had since I was a kid. Whenever I’d play the board game CLUE with my family, we’d always run out of the paper notecards. The idea behind this app is to replace the physical notecards with an electronic one, allowing players to digitally track suspects, weapons, and rooms across rounds of gameplay. 
The app is intended to be lightweight, intuitive, and usable during live board game sessions without disrupting play. CLUEper is planned for release on the Apple iOS App Store, hopefully before I graduate near the end of this semester.

Official Rules to the board game CLUE: https://www.hasbro.com/common/instruct/clueins.pdf
(Will need to build code logic around these rules)

GOALS
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
Replace the physical Clue notecard with a digital notecard.

Track each round of physical gameplay and use this information to update the notecard.

Ensure the UI is simple enough to use while playing a physical game.

Prepare the app for eventual iOS App Store release

Milestone 3: I would like to get the legend removed from the AI assistant page. I was originally planning on completing that analysis page next. I will be renaming it since it won't be using any API for any AI chat.. It'll be hard-coded. But for now, I think I'm going to use Milestone 3 to tranfer the whole project over to react. 


FEATURES
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
Preloaded Clue categories:
Suspects
Weapons
Rooms

Toggle or mark cards as:
<img width="193" height="22" alt="Screenshot 2026-03-10 115157" src="https://github.com/user-attachments/assets/472d0ce2-21f2-4d5b-8fce-bcf061d12c70" />


Round logging:
Track which player should play a card. If it were you making the accusation, what cards were you shown?
<img width="325" height="669" alt="Screenshot 2026-03-10 113555" src="https://github.com/user-attachments/assets/db7eda9d-6c91-4f0f-bf90-33ae1d537c60" />

Optional additional notes.
- I have yet to implement this. I did make it possible for you to override the icon in the DetectiveNotes boxes.

Game reset functionality
- No current way to save game mid-progress or start a separate game. (Save game might be nice if you close out of the app or step out for whatever reason. I'm not sure if there's much point in adding the ability to have another game seperate to current game. 


________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________


TECHNOLOGY STACK
_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Platform: iOS
Language: Swift
Framework: SwiftUI
IDE: Xcode


Version Control: Git & GitHub
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________



PROTOTYPE
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
SwiftUI screen mockup showing: Example of using Xcode and SwiftUI


<img width="1440" height="900" alt="Screenshot 2026-02-05 at 12 27 45 PM" src="https://github.com/user-attachments/assets/6a06ccd8-fbda-4f40-a545-34b761667d86" />
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

<img width="287" height="602" alt="Screenshot 2026-02-05 at 12 31 48 PM" src="https://github.com/user-attachments/assets/06a2ba46-116f-4fad-99a4-f257aed15059" />
<img width="307" height="607" alt="Screenshot 2026-02-05 at 12 35 39 PM" src="https://github.com/user-attachments/assets/2b3ae9bf-7dab-4c49-84ba-5fcb8932c0cf" />

________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________



FOLDER STRUCTURE
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
Milestone 1
TBD… Every page so far has its own file, like "progress bar," which is used more than once. I would like to overhaul the file structure and add some folders. 

Milestone 2 update:
CLUEper
│
├── Views
│   ├── WelcomeView
│   ├── NewGameView
│   ├── PlayerSetupView
│   ├── CardSelectionView
│   ├── DetectiveNotesView
│   └── RoundLogView
│
├── Models
│   └── Player.swift
│
├── Components
│   ├── ProgressBar
│   └── Reusable UI Components
│
└── Assets

Milestone 3 update:

CLUEper
│
├── CLUEperApp.swift
│
├── Data
│   └── ClueCards.swift
│
├── Engines
│   ├── AnalysisEngine.swift
│   ├── DeductionEngine.swift
│   ├── GameSetupEngine.swift
│   └── PlayerStatusEngine.swift
│
├── Modals
│   ├── AnalysisResult.swift
│   ├── CellState.swift
│   ├── LogEntry.swift
│   ├── NotesTab.swift
│   ├── Player.swift
│   ├── Row.swift
│   └── SavedGame.swift
│
├── ViewModals
│   ├── GameViewModal.swift
│   └── SavedGamesStore.swift
│
├── Views
│   ├── AnalysisRowView.swift
│   ├── AppColors.swift
│   ├── AppFeedback.swift
│   ├── CellView.swift
│   ├── DetectiveNotesView.swift
│   ├── LogView.swift
│   ├── MarqueeText.swift
│   ├── NewGameCardSelectView.swift
│   ├── NewGameFlowView.swift
│   ├── NewGamePlayerCountView.swift
│   ├── NewGamePlayerSelectView.swift
│   ├── NotesView.swift
│   ├── ProgressBar.swift
│   ├── RootView.swift
│   ├── RoundLogEntryView.swift
│   └── WelcomeView.swift
│
└── Images
└── Assets.xcassets



CURRENT STATUS
________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

MileStone Update 1:
Currently designing all the different pages for this IOS app, WelcomeView -> NewGameView -> SetupPages. Next, I plan on adding the detective note page, which will be where you can see your notecard and log game rounds, you will have the ability to update your notecard automatically, or it will be updated from the logs. Deduction logic yet to be determined. I also plan for near the end of milestone 2 starting an AI probability screen to show you the likelihood of certain cards being in the middle based on deductions you made.

Milestone Update 2:
We now have the ability to log which cards you have and view the DetectiveNotesView you than have tabs at the top of the screen as shown here:
<img width="300" height="137" alt="Screenshot 2026-03-10 115720" src="https://github.com/user-attachments/assets/eba1d903-6b3c-412d-899c-2ec4dbcd97d5" />

This allows you to tab over to the previous logs of recorded game rounds that you create when clicking on the +log option. The AI probability page is yet to be implemented however simple rules are already auto checking off things in your DetectiveNotesView screen. For example when recording a round if you say someone showed you a certain card that card will automatically be checked off on the Notes page. (I do still need to make it give a red "x" for everyone else, as you can't have more than one of the same card.

Milestone Update3: 
We have a detective analysis page! This page pulls directly from the recorded logs it will update probability of whay is likely to be in the middle and what guess is your best accusation as well as attempt to show you how high a threat other players could be with information they should know. (Obviously they may not being using this app and could make mistakes and be further from knowing than the app shows in real life) I have also implemented a save feature if you were to pause the game and come back to it later, as well as the abiilty delete last recorded round incase you miss entered information. 
<img width="544" height="1124" alt="image" src="https://github.com/user-attachments/assets/96a2f6e9-60f4-4264-a468-3e085f04d8c9" /><img width="252" height="550" alt="Screenshot 2026-04-24 at 4 51 14 PM" src="https://github.com/user-attachments/assets/8d794690-da40-4cc0-bdf1-27f1ed977ba8" />


________________________________________________________________________________________________________________________________________________________________________________________


5 Minute Video - MileStone1 


https://mediaspace.wisconsin.edu/media/Kaltura+Capture+recording+-+February+12th+2026%2C+1%3A44%3A12+pm/1_g767bacv
________________________________________________________________________________________________________________________________________________________________________


5 Minute Video - MileStone2
________________________________________________________________________________________________________________________________________________________________________


https://mediaspace.wisconsin.edu/media/Kaltura+Capture+recording+-+March+27th+2026%2C+5%3A54%3A13+pm/1_agab9qt5


5 Minute Video - MileStone3
________________________________________________________________________________________________________________________________________________________________________

