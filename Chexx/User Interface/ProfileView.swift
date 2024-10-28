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

private enum FocusableField: Hashable {
    case email
    case password
    case displayName
}

struct Country: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
}

struct ProfileView: View {
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    
    @State private var isEditing = false
    @State private var isKeyboardVisible = false
    @State private var newDisplayName: String = ""
    @State private var password = ""
    
    @State private var selectedCountry: Country? = nil // Store the selected country
    @State private var countries: [Country] = [
        Country(emoji: "🇦🇫", name: "Afghanistan"),
        Country(emoji: "🇦🇱", name: "Albania"),
        Country(emoji: "🇩🇿", name: "Algeria"),
        Country(emoji: "🇦🇸", name: "American Samoa"),
        Country(emoji: "🇦🇩", name: "Andorra"),
        Country(emoji: "🇦🇴", name: "Angola"),
        Country(emoji: "🇦🇮", name: "Anguilla"),
        Country(emoji: "🇦🇬", name: "Antigua and Barbuda"),
        Country(emoji: "🇦🇷", name: "Argentina"),
        Country(emoji: "🇦🇲", name: "Armenia"),
        Country(emoji: "🇦🇼", name: "Aruba"),
        Country(emoji: "🇦🇺", name: "Australia"),
        Country(emoji: "🇦🇹", name: "Austria"),
        Country(emoji: "🇦🇿", name: "Azerbaijan"),
        Country(emoji: "🇧🇸", name: "Bahamas"),
        Country(emoji: "🇧🇭", name: "Bahrain"),
        Country(emoji: "🇧🇩", name: "Bangladesh"),
        Country(emoji: "🇧🇧", name: "Barbados"),
        Country(emoji: "🇧🇾", name: "Belarus"),
        Country(emoji: "🇧🇪", name: "Belgium"),
        Country(emoji: "🇧🇿", name: "Belize"),
        Country(emoji: "🇧🇯", name: "Benin"),
        Country(emoji: "🇧🇲", name: "Bermuda"),
        Country(emoji: "🇧🇹", name: "Bhutan"),
        Country(emoji: "🇧🇴", name: "Bolivia"),
        Country(emoji: "🇧🇦", name: "Bosnia and Herzegovina"),
        Country(emoji: "🇧🇼", name: "Botswana"),
        Country(emoji: "🇧🇷", name: "Brazil"),
        Country(emoji: "🇻🇬", name: "British Virgin Islands"),
        Country(emoji: "🇻🇨", name: "Saint Vincent and the Grenadines"),
        Country(emoji: "🇧🇳", name: "Brunei"),
        Country(emoji: "🇧🇬", name: "Bulgaria"),
        Country(emoji: "🇧🇫", name: "Burkina Faso"),
        Country(emoji: "🇧🇮", name: "Burundi"),
        Country(emoji: "🇨🇻", name: "Cabo Verde"),
        Country(emoji: "🇨🇲", name: "Cameroon"),
        Country(emoji: "🇰🇭", name: "Cambodia"),
        Country(emoji: "🇨🇦", name: "Canada"),
        Country(emoji: "🇰🇾", name: "Cayman Islands"),
        Country(emoji: "🇨🇫", name: "Central African Republic"),
        Country(emoji: "🇹🇩", name: "Chad"),
        Country(emoji: "🇨🇱", name: "Chile"),
        Country(emoji: "🇨🇳", name: "China"),
        Country(emoji: "🇨🇴", name: "Colombia"),
        Country(emoji: "🇰🇲", name: "Comoros"),
        Country(emoji: "🇨🇩", name: "Congo - Kinshasa"),
        Country(emoji: "🇨🇬", name: "Congo - Brazzaville"),
        Country(emoji: "🇨🇷", name: "Costa Rica"),
        Country(emoji: "🇭🇷", name: "Croatia"),
        Country(emoji: "🇨🇺", name: "Cuba"),
        Country(emoji: "🇨🇼", name: "Curaçao"),
        Country(emoji: "🇨🇾", name: "Cyprus"),
        Country(emoji: "🇨🇿", name: "Czech Republic"),
        Country(emoji: "🇩🇰", name: "Denmark"),
        Country(emoji: "🇩🇯", name: "Djibouti"),
        Country(emoji: "🇩🇲", name: "Dominica"),
        Country(emoji: "🇩🇴", name: "Dominican Republic"),
        Country(emoji: "🇪🇨", name: "Ecuador"),
        Country(emoji: "🇪🇬", name: "Egypt"),
        Country(emoji: "🇸🇻", name: "El Salvador"),
        Country(emoji: "🇬🇶", name: "Equatorial Guinea"),
        Country(emoji: "🇪🇷", name: "Eritrea"),
        Country(emoji: "🇪🇪", name: "Estonia"),
        Country(emoji: "🇪🇹", name: "Ethiopia"),
        Country(emoji: "🇫🇯", name: "Fiji"),
        Country(emoji: "🇫🇮", name: "Finland"),
        Country(emoji: "🇫🇷", name: "France"),
        Country(emoji: "🇬🇦", name: "Gabon"),
        Country(emoji: "🇬🇲", name: "Gambia"),
        Country(emoji: "🇬🇪", name: "Georgia"),
        Country(emoji: "🇩🇪", name: "Germany"),
        Country(emoji: "🇬🇭", name: "Ghana"),
        Country(emoji: "🇬🇷", name: "Greece"),
        Country(emoji: "🇬🇩", name: "Grenada"),
        Country(emoji: "🇬🇺", name: "Guam"),
        Country(emoji: "🇬🇹", name: "Guatemala"),
        Country(emoji: "🇬🇬", name: "Guernsey"),
        Country(emoji: "🇬🇳", name: "Guinea"),
        Country(emoji: "🇬🇼", name: "Guinea-Bissau"),
        Country(emoji: "🇬🇾", name: "Guyana"),
        Country(emoji: "🇭🇹", name: "Haiti"),
        Country(emoji: "🇭🇳", name: "Honduras"),
        Country(emoji: "🇭🇰", name: "Hong Kong"),
        Country(emoji: "🇭🇺", name: "Hungary"),
        Country(emoji: "🇮🇸", name: "Iceland"),
        Country(emoji: "🇮🇳", name: "India"),
        Country(emoji: "🇮🇩", name: "Indonesia"),
        Country(emoji: "🇮🇷", name: "Iran"),
        Country(emoji: "🇮🇶", name: "Iraq"),
        Country(emoji: "🇮🇪", name: "Ireland"),
        Country(emoji: "🇮🇲", name: "Isle of Man"),
        Country(emoji: "🇮🇱", name: "Israel"),
        Country(emoji: "🇮🇹", name: "Italy"),
        Country(emoji: "🇯🇲", name: "Jamaica"),
        Country(emoji: "🇯🇵", name: "Japan"),
        Country(emoji: "🇯🇪", name: "Jersey"),
        Country(emoji: "🇯🇴", name: "Jordan"),
        Country(emoji: "🇰🇿", name: "Kazakhstan"),
        Country(emoji: "🇰🇪", name: "Kenya"),
        Country(emoji: "🇰🇮", name: "Kiribati"),
        Country(emoji: "🇰🇼", name: "Kuwait"),
        Country(emoji: "🇰🇬", name: "Kyrgyzstan"),
        Country(emoji: "🇱🇦", name: "Laos"),
        Country(emoji: "🇱🇻", name: "Latvia"),
        Country(emoji: "🇱🇧", name: "Lebanon"),
        Country(emoji: "🇱🇸", name: "Lesotho"),
        Country(emoji: "🇱🇷", name: "Liberia"),
        Country(emoji: "🇱🇾", name: "Libya"),
        Country(emoji: "🇱🇮", name: "Liechtenstein"),
        Country(emoji: "🇱🇹", name: "Lithuania"),
        Country(emoji: "🇱🇺", name: "Luxembourg"),
        Country(emoji: "🇲🇴", name: "Macau"),
        Country(emoji: "🇲🇰", name: "North Macedonia"),
        Country(emoji: "🇲🇬", name: "Madagascar"),
        Country(emoji: "🇲🇼", name: "Malawi"),
        Country(emoji: "🇲🇾", name: "Malaysia"),
        Country(emoji: "🇲🇻", name: "Maldives"),
        Country(emoji: "🇲🇱", name: "Mali"),
        Country(emoji: "🇲🇹", name: "Malta"),
        Country(emoji: "🇲🇭", name: "Marshall Islands"),
        Country(emoji: "🇲🇶", name: "Martinique"),
        Country(emoji: "🇲🇷", name: "Mauritania"),
        Country(emoji: "🇲🇺", name: "Mauritius"),
        Country(emoji: "🇾🇹", name: "Mayotte"),
        Country(emoji: "🇲🇽", name: "Mexico"),
        Country(emoji: "🇫🇲", name: "Micronesia"),
        Country(emoji: "🇲🇩", name: "Moldova"),
        Country(emoji: "🇲🇨", name: "Monaco"),
        Country(emoji: "🇲🇳", name: "Mongolia"),
        Country(emoji: "🇲🇪", name: "Montenegro"),
        Country(emoji: "🇲🇸", name: "Montserrat"),
        Country(emoji: "🇲🇦", name: "Morocco"),
        Country(emoji: "🇲🇿", name: "Mozambique"),
        Country(emoji: "🇲🇲", name: "Myanmar"),
        Country(emoji: "🇳🇦", name: "Namibia"),
        Country(emoji: "🇳🇷", name: "Nauru"),
        Country(emoji: "🇳🇵", name: "Nepal"),
        Country(emoji: "🇳🇱", name: "Netherlands"),
        Country(emoji: "🇳🇨", name: "New Caledonia"),
        Country(emoji: "🇳🇿", name: "New Zealand"),
        Country(emoji: "🇳🇮", name: "Nicaragua"),
        Country(emoji: "🇳🇪", name: "Niger"),
        Country(emoji: "🇳🇬", name: "Nigeria"),
        Country(emoji: "🇳🇺", name: "Niue"),
        Country(emoji: "🇳🇫", name: "Norfolk Island"),
        Country(emoji: "🇰🇵", name: "North Korea"),
        Country(emoji: "🇲🇵", name: "Northern Mariana Islands"),
        Country(emoji: "🇳🇴", name: "Norway"),
        Country(emoji: "🇴🇲", name: "Oman"),
        Country(emoji: "🇵🇰", name: "Pakistan"),
        Country(emoji: "🇵🇼", name: "Palau"),
        Country(emoji: "🇵🇸", name: "Palestine"),
        Country(emoji: "🇵🇦", name: "Panama"),
        Country(emoji: "🇵🇬", name: "Papua New Guinea"),
        Country(emoji: "🇵🇾", name: "Paraguay"),
        Country(emoji: "🇵🇪", name: "Peru"),
        Country(emoji: "🇵🇭", name: "Philippines"),
        Country(emoji: "🇵🇳", name: "Pitcairn Islands"),
        Country(emoji: "🇵🇱", name: "Poland"),
        Country(emoji: "🇵🇹", name: "Portugal"),
        Country(emoji: "🇵🇷", name: "Puerto Rico"),
        Country(emoji: "🇶🇦", name: "Qatar"),
        Country(emoji: "🇷🇴", name: "Romania"),
        Country(emoji: "🇷🇺", name: "Russia"),
        Country(emoji: "🇷🇼", name: "Rwanda"),
        Country(emoji: "🇷🇪", name: "Réunion"),
        Country(emoji: "🇼🇸", name: "Samoa"),
        Country(emoji: "🇸🇲", name: "San Marino"),
        Country(emoji: "🇸🇹", name: "São Tomé & Príncipe"),
        Country(emoji: "🇸🇦", name: "Saudi Arabia"),
        Country(emoji: "🇸🇳", name: "Senegal"),
        Country(emoji: "🇷🇸", name: "Serbia"),
        Country(emoji: "🇸🇨", name: "Seychelles"),
        Country(emoji: "🇸🇱", name: "Sierra Leone"),
        Country(emoji: "🇸🇬", name: "Singapore"),
        Country(emoji: "🇸🇽", name: "Sint Maarten"),
        Country(emoji: "🇸🇰", name: "Slovakia"),
        Country(emoji: "🇸🇮", name: "Slovenia"),
        Country(emoji: "🇸🇧", name: "Solomon Islands"),
        Country(emoji: "🇸🇴", name: "Somalia"),
        Country(emoji: "🇿🇦", name: "South Africa"),
        Country(emoji: "🇬🇸", name: "South Georgia & South Sandwich Islands"),
        Country(emoji: "🇰🇷", name: "South Korea"),
        Country(emoji: "🇸🇸", name: "South Sudan"),
        Country(emoji: "🇪🇸", name: "Spain"),
        Country(emoji: "🇱🇰", name: "Sri Lanka"),
        Country(emoji: "🇸🇩", name: "Sudan"),
        Country(emoji: "🇸🇷", name: "Suriname"),
        Country(emoji: "🇸🇿", name: "Eswatini (Swaziland)"),
        Country(emoji: "🇸🇪", name: "Sweden"),
        Country(emoji: "🇨🇭", name: "Switzerland"),
        Country(emoji: "🇸🇾", name: "Syria"),
        Country(emoji: "🇹🇼", name: "Taiwan"),
        Country(emoji: "🇹🇯", name: "Tajikistan"),
        Country(emoji: "🇹🇿", name: "Tanzania"),
        Country(emoji: "🇹🇭", name: "Thailand"),
        Country(emoji: "🇹🇱", name: "Timor-Leste"),
        Country(emoji: "🇹🇬", name: "Togo"),
        Country(emoji: "🇹🇰", name: "Tokelau"),
        Country(emoji: "🇹🇴", name: "Tonga"),
        Country(emoji: "🇹🇹", name: "Trinidad and Tobago"),
        Country(emoji: "🇹🇳", name: "Tunisia"),
        Country(emoji: "🇹🇷", name: "Turkey"),
        Country(emoji: "🇹🇲", name: "Turkmenistan"),
        Country(emoji: "🇹🇻", name: "Tuvalu"),
        Country(emoji: "🇺🇬", name: "Uganda"),
        Country(emoji: "🇺🇦", name: "Ukraine"),
        Country(emoji: "🇦🇪", name: "United Arab Emirates"),
        Country(emoji: "🇬🇧", name: "United Kingdom"),
        Country(emoji: "🇺🇸", name: "United States"),
        Country(emoji: "🇺🇾", name: "Uruguay"),
        Country(emoji: "🇺🇿", name: "Uzbekistan"),
        Country(emoji: "🇻🇺", name: "Vanuatu"),
        Country(emoji: "🇻🇦", name: "Vatican City"),
        Country(emoji: "🇻🇪", name: "Venezuela"),
        Country(emoji: "🇻🇳", name: "Vietnam"),
        Country(emoji: "🇼🇫", name: "Wallis & Futuna"),
        Country(emoji: "🇪🇭", name: "Western Sahara"),
        Country(emoji: "🇾🇪", name: "Yemen"),
        Country(emoji: "🇿🇲", name: "Zambia"),
        Country(emoji: "🇿🇼", name: "Zimbabwe")
    ]
    
    var body: some View {
        let minDimension = min(self.screenHeight, self.screenWidth)
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
                
                VStack {
                    if isEditing {
                        TextField("Enter new display name", text: $newDisplayName)
                            .focused($focus, equals: .displayName)
                            .onSubmit {
                            if !newDisplayName.isEmpty {
                                authViewModel.updateUserNameInFirestore(name: newDisplayName)
                                newDisplayName = ""
                            }
                            isEditing = false
                            focus = nil
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    } else {
                        HStack {
                            Text("Display Name:  \(authViewModel.displayName)")
                                .font(.system(size: minDimension / 18, weight: .bold, design: .serif))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                newDisplayName = "" //authViewModel.displayName // Load current username for editing
                                isEditing = true // Enter editing mode
                                focus = .displayName
                            }) {
                                Image(systemName: "pencil")
                                    .font(.headline)
                                    .foregroundColor(.black) // Change color as needed
                            }
                            .padding(.leading, 5)
                        }
                        .onChange(of: isEditing) {
                            if isEditing {
                                focus = .displayName
                            }
                        }
                    }
                }
                //.padding(.bottom)
                
                // Country Selection Section
                HStack {
                    Text("Representing:")
                        //.font(.title)
                        .font(.system(size: minDimension / 18, weight: .bold, design: .serif))
                    
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in // Use id: \.self
                            Text("\(country.emoji) \(country.name)").tag(country as Country?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Change this to your preferred style
                    .onAppear {
                        loadSelectedCountry() // Load the selected country when the view appears
                    }
                    .onChange(of: selectedCountry) {
                        // Update Firebase Firestore (server storage)
                        authViewModel.userCountry = selectedCountry!.name
                        authViewModel.updateUserCountryInFirestore(country: selectedCountry!.name)
                        
                        //update local storage
                        UserDefaults.standard.set(selectedCountry?.name, forKey: "country") // Persist the selection
                    }
                }
                
                Text("Hex Chess Elo Rating:  \(authViewModel.eloScore)")
                    .font(.system(size: minDimension / 18, weight: .bold, design: .serif))
                    //.lineLimit(1)
                    //.multilineTextAlignment(.leading)
                    .padding(.bottom, screenHeight / 30)
                
                Divider()
                    .padding(.bottom, screenHeight / 24)
                
                // Navigation buttons to different sections
                VStack(spacing: 20) {
                    
                    if !isKeyboardVisible {
                        Button(action: gameHistory) {
                            Text("Game History")
                                .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                                .padding()
                                .frame(height: screenHeight / 18)
                                .background(Color.accentColor)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(HexagonEdgeRectangleShape())
                                .padding(.bottom , screenHeight / 20)
                        }
                        
                        // Sign Out Button
                        Button(action: authViewModel.signOut) { //maybe make this smaller?
                            Text("Sign Out")
                                .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                                .padding()
                                .frame(width: screenHeight / 4.5, height: screenHeight / 18)
                                .background(Color.red)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(HexagonEdgeRectangleShape())
                        }
                    }
                }
                .padding(.top)
                .onAppear { //seeing if the keyboard is on the screen, hides other button options
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = true
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        isKeyboardVisible = false
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                }
            
                
/*
 SIGN IN SCREEN
 */
                
                
            } else { //NOT LOGGED IN

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    //Image(systemName: "at")
                    TextField("Email", text: $authViewModel.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .focused($focus, equals: .email)
                        .submitLabel(.next) //show "next" on the keyboard
                        .onSubmit {
                            self.focus = .password // Move to password field when "Next" is pressed
                        }
                }
                //.padding(.vertical, 6)
                //.background(Divider(), alignment: .bottom)
                //.padding(.bottom, 4)
                
                HStack {
                    //Image(systemName: "lock")
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .focused($focus, equals: .password)
                        .submitLabel(.go) // Show "Go" on the keyboard
                        .onSubmit {
                            authViewModel.signInWithEmail(email: authViewModel.email, password: password) // Call login function when "Go" is pressed
                        }
                }
                //.padding(.vertical, 6)
                //.background(Divider(), alignment: .bottom)
                //.padding(.bottom, 8)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                    Button(action: {
                        authViewModel.sendPasswordReset(email: authViewModel.email)
                    }) {
                        Text("Reset Password")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    //.padding()
                    
                }
                    
                HStack{
                    Button(action: { authViewModel.signInWithEmail(email: authViewModel.email, password: password) }) {
                        Text("Sign In")
                            .padding()
                            .background(Color(.systemGray4))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: { authViewModel.registerWithEmail(email: authViewModel.email, password: password) }) {
                        Text("Register")
                            .padding()
                            .background(Color(.systemGray4))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                
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
    
    func loadSelectedCountry() {
        // First, try loading the country from UserDefaults
        if let savedCountryName = UserDefaults.standard.string(forKey: "country"),
           let country = countries.first(where: { $0.name == savedCountryName }) {
            // If found in UserDefaults and matches a known country, assign it
            selectedCountry = country
        }
        
        // Regardless of whether it's found locally, attempt to load the latest from Firestore
        //if theres no service, the function should still update selectedCountry to what is found on the hard drive
        authViewModel.loadUserCountryFromFirestore { loadedCountry in
            if let loadedCountry = loadedCountry,
               let country = self.countries.first(where: { $0.name == loadedCountry }) {
                // Update the selectedCountry from Firestore
                self.selectedCountry = country
            }
        }
    }
}



//can remove below for production:
#Preview {
    ProfileView(screenHeight: 720, screenWidth: 200) //??????
}
