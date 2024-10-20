//
//  AuthViewModel.swift
//  Chexx
//
//  Created by Sawyer Christensen on 10/18/24.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
//need to implement sign in with apple & facebook

@MainActor
class AuthViewModel: ObservableObject {
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
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if self.isLoggedIn {
            restoreUserData()
        }
    }
    
    func restoreUserData() {
        self.email = UserDefaults.standard.string(forKey: "email") ?? ""
        self.displayName = UserDefaults.standard.string(forKey: "displayName") ?? ""
        if let imageUrlString = UserDefaults.standard.string(forKey: "profileImageURL") {
            self.profileImageURL = URL(string: imageUrlString)
        }
        self.userCountry = UserDefaults.standard.string(forKey: "country") ?? ""
        self.eloScore = UserDefaults.standard.integer(forKey: "eloScore")
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
            

            // Persist user details
            UserDefaults.standard.set(self.email, forKey: "email")
            UserDefaults.standard.set(self.displayName, forKey: "displayName")
            if let imageURL = self.profileImageURL?.absoluteString {
                UserDefaults.standard.set(imageURL, forKey: "profileImageURL")
            }
            
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
            
            // Persist login state and user details
            UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
            UserDefaults.standard.set(self.email, forKey: "email")
            UserDefaults.standard.set(self.displayName, forKey: "displayName")
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
            
            // Persist login state and user details
            UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
            UserDefaults.standard.set(self.email, forKey: "email")
            UserDefaults.standard.set(self.displayName, forKey: "displayName")

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
    }
}
