//
//  ProfileView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct ProfileView: View {
    let screenHeight: CGFloat
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme
    @EnvironmentObject var authViewModel: AuthViewModel
    var userUsingEmail: Bool = false
    var userUsingGoogle: Bool = false
    var userUsingApple: Bool = false
    var userUsingFacebook: Bool = false
    
    @State private var password = ""
    
    
    var body: some View {
        VStack {
            
            if authViewModel.isLoggedIn { //LOGGED IN!
                
                if let theProfileImageURL = authViewModel.profileImageURL {
                    AsyncImage(url: theProfileImageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle()) // Make it circular
                            .frame(width: 100, height: 100) // Set size for the image
                            .padding()
                    } placeholder: {
                        ProgressView() // Show a loading spinner while the image loads
                    }
                }
                
                Text("Welcome, \(authViewModel.displayName)!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                // Navigation buttons to different sections
                VStack(spacing: 20) {
                    
                    Button(action: gameHistory) {
                        Text("Game History")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // Sign Out Button
                    Button(action: authViewModel.signOut) {
                        Text("Sign Out")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top)
                
            } else { //NOT LOGGED IN
                // Sign In Form
                Text("Login / Create an account with:")
                    .font(.title2)
                    .padding(.bottom)
                
                TextField("Email", text: $authViewModel.email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: { authViewModel.signInWithEmail(email: authViewModel.email, password: password) }) {
                    Text("Sign In")
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: { authViewModel.registerWithEmail(email: authViewModel.email, password: password) }) {
                    Text("Register")
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                HStack{
                    VStack { Divider() }
                    Text("or")
                    VStack { Divider() }
                }
                
                Button(action: {
                    Task {
                        await authViewModel.signInWithGoogle()
                    }
                }) {
                    Text("Sign in with Google")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(alignment: .leading) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 32, height: 32, alignment: .center)
                        }
                }
                .buttonStyle(.bordered)
                
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .padding()
    }
    
    // Example functions for navigation
    private func startNewGame() {
        // Code to start a new game
    }
    
    private func viewProfile() {
        // Code to navigate to the profile view
    }
    
    private func gameHistory() {
        // Code to view game history
    }
    
}



//can remove below for production:
#Preview {
    ProfileView(screenHeight: 720)
}
