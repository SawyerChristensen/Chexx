//
//  AuthViewModel.swift
//  Chexx
//
//  Created by Sawyer Christensen on 10/18/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
//need to implement sign in with apple & facebook

@MainActor
class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var isLoggedIn: Bool = false {
        didSet {
            // Persist login state
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    @Published var email: String = ""
    @Published var displayName: String = ""
    @Published var profileImageURL: URL?
    @Published var errorMessage: String = ""
    @Published var userCountry: String = ""
    @Published var eloScore: Int = 800 // the default ELO score
    
    let db = Firestore.firestore() //db for database (were using firestore)
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if self.isLoggedIn {
            fetchUserDataFromHardDrive() //get data from local hard drive first (faster) (also just in case theres no connection)
            fetchUserDataFromFirestore { //get the data from the server and wait until we get a response
                self.saveUserDataToDevice() //save the most recent data just in case
            }
        } else {
            // If not logged in, sign in anonymously? (this is currently not allowed)
            if Auth.auth().currentUser == nil {
                Auth.auth().signInAnonymously { (authResult, error) in
                    if let error = error {
                        print("Anonymous sign-in failed: \(error)")
                        // Handle error if needed, maybe retry or set default state
                    } else {
                        print("Anonymous sign-in succeeded.")
                        //self.isLoggedIn = true
                        // Optionally fetch user data if needed
                    }
                }
            }
        }
    }
    
    func fetchUserDataFromHardDrive() { //gets the local data from the hard drive
        self.email = UserDefaults.standard.string(forKey: "email") ?? "none found on hard drive"
        self.displayName = UserDefaults.standard.string(forKey: "displayName") ?? "none found on hard drive"
        if let imageUrlString = UserDefaults.standard.string(forKey: "profileImageURL") {
            self.profileImageURL = URL(string: imageUrlString)
        }
        self.userCountry = UserDefaults.standard.string(forKey: "country") ?? "none found on hard drive"
        if (UserDefaults.standard.integer(forKey: "eloScore")) == 0 {
            self.eloScore = -1
        }
        
        /* print("Local Email: \(self.email)")
        print("Local Display Name: \(self.displayName)")
        print("Local Country: \(self.userCountry)")
        print("Local ELO Score: \(self.eloScore)") */
        
    }
    
    func fetchUserDataFromFirestore(completion: @escaping () -> Void) { //gets the latest data from the server & saves it to device
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        //if theres no data in firestore, we need the values set to default
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                //print("User document found: \(document.documentID)")
                let data = document.data()
                //print(data!)
                
                self.email = data?["email"] as? String ?? "none found on server" //this is only called if the data DOES exist, so the ?? should never be triggered
                self.displayName = data?["displayName"] as? String ?? "none found on server"
                self.userCountry = data?["country"] as? String ?? "none found on server"
                self.eloScore = data?["eloScore"] as? Int ?? 800 //does NOT set the Elo to 800, ?? should never be called. the alternative is force unwrapping it with ! but this gets the point across of what SHOULD happen elsewhere in the code (down below)
                
                if self.eloScore == 0 {
                    self.eloScore = 800
                }
                
                /* print("Firestore Email: \(self.email)")
                print("Firestore Display Name: \(self.displayName)")
                print("Firestore Country: \(self.userCountry)")
                print("Firestore ELO Score: \(self.eloScore)") */

            } else {
                print("No Firestore document found for this user.")
                //so make one!
                self.saveUserDataToFirestore()
            }
            
            //this is so the other local code waits to execute until after this funciton is finished
            completion()
        }
    }
    
    func fetchUserDataByUserId(_ userId: String, completion: @escaping (String?, String?) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                completion(nil, nil)
                return
            }
            
            guard let data = document?.data() else {
                print("No Firestore document found for userId: \(userId)")
                completion(nil, nil)
                return
            }
            
            //print("Fetched user data: \(data)") // Debugging
            
            let displayName = data["displayName"] as? String
            let profileImageURL = data["profileImageURL"] as? String
            
            //print("Fetched displayName: \(displayName ?? "None"), profileImageURL: \(profileImageURL ?? "None")") // Debugging
            
            completion(displayName, profileImageURL)
        }
    }

    
    func saveUserDataToFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Prepare the data to save
        var userData: [String: Any] = [
            "email": self.email,
            "displayName": self.displayName,
            "country": self.userCountry,
            "eloScore": self.eloScore
        ]
        
        // Add profileImageURL ONLY if it exists
        if let profileImageURL = self.profileImageURL?.absoluteString {
            userData["profileImageURL"] = profileImageURL
        }

        // Save the data in Firestore under the user's document
        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data successfully saved to Firestore.")
            }
        }
    }
    
    func saveUserDataToDevice() {
        UserDefaults.standard.set(self.email, forKey: "email")
        UserDefaults.standard.set(self.displayName, forKey: "displayName")
        UserDefaults.standard.set(self.userCountry, forKey: "country")
        UserDefaults.standard.set(self.eloScore, forKey: "eloScore")
    }
    
    func updateUserNameInFirestore(name: String) {
        // Ensure the name is not empty or nil and does not match the stored value
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in to update name.")
            return
        }

        // Load the current stored name from UserDefaults
        let currentStoredName = UserDefaults.standard.string(forKey: "displayName") ?? ""

        // Check if the new name is different from the stored name
        if name.isEmpty {
            print("Name is empty, not updating Firestore.")
            return
        }

        if currentStoredName != name {
            // Update the `displayName` field in Firestore
            db.collection("users").document(userID).updateData([
                "displayName": name
            ]) { error in
                if let error = error {
                    print("Error updating name in Firestore: \(error.localizedDescription)")
                } else {
                    print("User name successfully updated to \(name).")
                    
                    // Optionally update the local UserDefaults after successful update
                    UserDefaults.standard.set(name, forKey: "displayName")
                }
            }
        } else {
            print("Name is the same as the stored value, no update needed.")
        }
        
        self.displayName = name
    }
    
    func updateUserCountryInFirestore(country: String) {
        // Ensure the country is not empty or nil and does not match the stored value
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in to update country.")
            return
        }
        
        // Check if the new country is different from the stored country
        if country.isEmpty {
            print("Country is empty, not updating Firestore.")
            return
        }

        // Load the current stored country from UserDefaults
        let currentStoredCountry = UserDefaults.standard.string(forKey: "country") ?? ""
        
        if currentStoredCountry != country {
            // Update the `userCountry` field in Firestore
            db.collection("users").document(userID).updateData([
                "country": country
            ]) { error in
                if let error = error {
                    print("Error updating country in Firestore: \(error.localizedDescription)")
                } else {
                    print("User country successfully updated to \(country).")
                    
                    // Optionally update the local UserDefaults after successful update
                    UserDefaults.standard.set(country, forKey: "country")
                }
            }
        } else {
            print("Country is the same as the stored value, no update needed.")
        }
    }
    
    func loadUserCountryFromFirestore(completion: @escaping (String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in to load country.")
            completion(nil) // Return nil if no user is logged in
            return
        }

        db.collection("users").document(userID).getDocument { document, error in
            if let error = error {
                print("Error loading user country from Firestore: \(error.localizedDescription)")
                completion(nil) // Return nil if there was an error
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let firestoreCountry = data?["country"] as? String ?? ""
                
                if !firestoreCountry.isEmpty {
                    self.userCountry = firestoreCountry
                    UserDefaults.standard.set(firestoreCountry, forKey: "country")
                    print("User country loaded from Firestore: \(firestoreCountry)")
                    completion(firestoreCountry) // Return the loaded country
                } else {
                    completion(nil) // Return nil if no country is found
                    print("No country found in Firestore.")
                }
            } else {
                print("User document does not exist.")
                completion(nil) // Return nil if the document does not exist
            }
        }
    }

    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ID token missing")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            
            let fullName = firebaseUser.displayName ?? user.profile?.name ?? "Player"
            let firstName = fullName.split(separator: " ").first.map(String.init) ?? "Player"
            
            self.isLoggedIn = true
            self.email = firebaseUser.email ?? "Unknown Email"
            self.displayName = firstName
            self.profileImageURL = URL(string: (user.profile?.imageURL(withDimension: 200)!.absoluteString)!)
            
            if let imageURL = self.profileImageURL?.absoluteString {
                UserDefaults.standard.set(imageURL, forKey: "profileImageURL")
            }
            
            self.fetchUserDataFromFirestore(completion: {}) //empty completion handler, we dont care if its asychronous here as long as it happens

            return true
            
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                // Check the error code
                let errorCode = AuthErrorCode(rawValue: error.code)
                
                // Log the actual error code to help debug
                print("Auth Error Code: \(error.code)")
                
                switch errorCode {
                case .wrongPassword:
                    // Email is recognized but the password is incorrect
                    self.errorMessage = "The password is incorrect. Please try again."
                //case .userNotFound:
                    // Email is not recognized, attempt to register the user
                    //self.registerWithEmail(email: email, password: password)
                    //print("registering user!")
                case .invalidEmail:
                    // Email format is invalid
                    self.errorMessage = "The email format is invalid."
                default:
                    // General error
                    self.registerWithEmail(email: email, password: password)
                    //self.errorMessage = "Error signing in: \(error.localizedDescription)"
                }
                return
            }
            self.isLoggedIn = true
            self.errorMessage = ""
            self.email = result?.user.email ?? "error@notfound.com" //this should never display if the error catching is working properly
            self.displayName = self.email
            
            self.fetchUserDataFromFirestore(completion: {})
        }
    }
    
    // Registration Function
    func registerWithEmail(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isLoggedIn = true
            self.errorMessage = ""
            self.email = result?.user.email ?? "error@notfound.com"
            self.displayName = self.email
            
            self.fetchUserDataFromFirestore(completion: {})
        }
    }
    
    func sendPasswordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = "Failed to send password reset: \(error.localizedDescription)"
                return
            }
            //sent password
            self.errorMessage = "Password reset email sent!"
        }
    }

    func signOut() {
       do {
           try Auth.auth().signOut()
           self.isLoggedIn = false
           self.email = ""
           self.displayName = ""
           self.userCountry = ""
           self.profileImageURL = URL("")
           
           // Remove saved data
           UserDefaults.standard.removeObject(forKey: "isLoggedIn")
           UserDefaults.standard.removeObject(forKey: "email")
           UserDefaults.standard.removeObject(forKey: "displayName")
           UserDefaults.standard.removeObject(forKey: "profileImageURL")
           UserDefaults.standard.removeObject(forKey: "country")
           UserDefaults.standard.removeObject(forKey: "elo")
           
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
        }
        //deleteUserAndData()
    }
    
    func deleteUserAndData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Reference to the Firestore document for the user
        let userDocumentRef = db.collection("users").document(userID)

        // Delete Firestore document first
        userDocumentRef.delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
                return
            }
            print("User Firestore document successfully deleted.")

            // Now delete the user from Firebase Authentication
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error deleting user account: \(error.localizedDescription)")
                } else {
                    print("User account successfully deleted.")
                }
            }
        }
    }
}
