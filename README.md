# Quests 🗺️  
_A location-based adventure platform for real-world challenges_

[🎥 Watch the Demo](#) 

---

## Overview

**Quests** is a SwiftUI mobile app (work in progress) that lets users create, share, and complete real-world, location-based challenges. 

---

## Features and Location in Code

**User Authentication**

The app uses Firebase Authentication to manage user sign-in. Users can log in using one of three supported methods:
1. Sign in with Google
2. Sign in with Apple
3. Username and Password. Enables users to register and sign in using custom credentials. Firebase handles password hashing, security, and session management.

To view the Authentication user interface code, go to Quests/Core Files/Authentication.

Helper functions that interact with the Firestore database can be found in Quests/Authentication.

**Quest Recommendation**

The main screen of the app consists of an infinite-scroll Quest recommendation system. This screen leverages the user's location to recommend nearby Quests (at an adjustable distance currently hard-set to 100km). This is implemented using Firebase’s GeoFire library, which enables efficient querying of location-based data via GeoHashes: compact representations of geographic coordinates. 
To fetch nearby quests, the app creates a set of GeoQueries centered around the user’s location. Each query retrieves results in paginated batches of 10, rather than fetching all results at once. The app keeps track of the last document retrieved for each query to enable smooth pagination.
As the user scrolls, more results are dynamically fetched and appended to the list, creating a seamless infinite scrolling experience while minimizing data transfer and improving performance.

To view the Quest recommendation code, go to Quests/Core Files/QuestRecommendation.

Helper functions for database retrieval and storage can be found in Quests/FireStore.

**Create Challenges**  

The "+" icon of the bottom tab bar takes the user to the Quest creation screen. This section is broken into smaller subsections where you:
1. Add a Title
2. Add a Description
3. Add a Starting Location
4. Add Objectives
5. Add Supporting Information

Note that Quests and Objectives are fully editable even after they've been created, so Quests can be modified and adjusted throughout their lifecycle. 

To view the Quest creation code, go to Quests/Core Files/CreateQuestFlow. 

**Profile Screen**

The Profile screen is found on the right side of the bottom tab bar. This screen keeps track of all the Quests that the authenticated user has created, completed, failed, or added to their watchlist. Users can manager their created Quests on this screen by editing, hiding, or deleting them, and can even begin playing a new Quest by clicking on one. 
For Quests being tracked on this screen, the app uses Firestore Listeners to react to real-time updates from the database, preventing stale data from being displayed to the user. 
Additionally, users can manage their personal settings on this screen by signing out, deleting their account, or updating their email/passwords based on the login type.

To view the Profile screen code, go to Quests/Core Files/Profile.

Helper functions for database retrieval and storage can be found in Quests/FireStore.

Helper functions for user authentication can be found in Quests/Authentication.

---

## Tech Stack

- **Swift / SwiftUI** – Frontend and UI
- **Firebase** – Firestore for real-time data, Authentication for user login
- **MapKit & CoreLocation** – For map display and user location
- **GeoFire** – Efficient geolocation querying in Firestore
- **Xcode** – Development environment


