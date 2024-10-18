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
    @Published var isLoggedIn: Bool = false
    @Published var email: String = ""
    @Published var displayName: String = ""
    @Published var profileImageURL: URL?
    @Published var errorMessage: String = ""

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
            
            let fullName = user.profile?.name ?? firebaseUser.displayName ?? "Player"
            let firstName = fullName.split(separator: " ").first.map(String.init) ?? "Player"
            
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.email = firebaseUser.email ?? "Unknown Email"
                self.displayName = firstName
                self.profileImageURL = URL(string: (user.profile?.imageURL(withDimension: 200)!.absoluteString)!)
            }
            return true
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.errorMessage = ""
                self.email = result?.user.email ?? "User"
            }
        }
    }
    
    // Registration Function
    func registerWithEmail(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.errorMessage = ""
                self.email = result?.user.email ?? "User"
            }
        }
    }

    func signOut() {
       do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.email = ""
            self.displayName = ""
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
        }
    }
}
