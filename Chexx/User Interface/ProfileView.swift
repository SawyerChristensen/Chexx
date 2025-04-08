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
import AuthenticationServices

private enum FocusableField: Hashable {
    case email
    case password
    case displayName
}

struct Country: Hashable {
    let code: String     // "US", "DE", "FR"
    let emoji: String    // "🇺🇸", "🇩🇪", "🇫🇷"

    var localizedName: String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

struct ProfileView: View {
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    
    @State private var gameCenterImage: UIImage?
    @State private var isEditing = false
    @State private var isKeyboardVisible = false
    @State private var showDeleteConfirmation = false
    @State private var newDisplayName: String = ""
    @State private var password = ""
    
    @State private var selectedCountry: Country? = nil
    @State private var countries: [Country] = [

        // A
        Country(code: "AF", emoji: "🇦🇫"),
        Country(code: "AL", emoji: "🇦🇱"),
        Country(code: "DZ", emoji: "🇩🇿"), // Algeria
        Country(code: "AS", emoji: "🇦🇸"),
        Country(code: "AD", emoji: "🇦🇩"),
        Country(code: "AO", emoji: "🇦🇴"),
        Country(code: "AI", emoji: "🇦🇮"),
        Country(code: "AG", emoji: "🇦🇬"),
        Country(code: "AR", emoji: "🇦🇷"),
        Country(code: "AM", emoji: "🇦🇲"),
        Country(code: "AW", emoji: "🇦🇼"),
        Country(code: "AU", emoji: "🇦🇺"),
        Country(code: "AT", emoji: "🇦🇹"),
        Country(code: "AZ", emoji: "🇦🇿"),

        // B
        Country(code: "BS", emoji: "🇧🇸"),
        Country(code: "BH", emoji: "🇧🇭"),
        Country(code: "BD", emoji: "🇧🇩"),
        Country(code: "BB", emoji: "🇧🇧"),
        Country(code: "BY", emoji: "🇧🇾"),
        Country(code: "BE", emoji: "🇧🇪"),
        Country(code: "BZ", emoji: "🇧🇿"),
        Country(code: "BJ", emoji: "🇧🇯"),
        Country(code: "BM", emoji: "🇧🇲"),
        Country(code: "BT", emoji: "🇧🇹"),
        Country(code: "BO", emoji: "🇧🇴"),
        Country(code: "BA", emoji: "🇧🇦"),
        Country(code: "BW", emoji: "🇧🇼"),
        Country(code: "BR", emoji: "🇧🇷"),
        Country(code: "VG", emoji: "🇻🇬"), // British Virgin Islands
        Country(code: "VC", emoji: "🇻🇨"), // Saint Vincent & Grenadines
        Country(code: "BN", emoji: "🇧🇳"),
        Country(code: "BG", emoji: "🇧🇬"),
        Country(code: "BF", emoji: "🇧🇫"),
        Country(code: "BI", emoji: "🇧🇮"),

        // C
        Country(code: "CV", emoji: "🇨🇻"),
        Country(code: "CM", emoji: "🇨🇲"),
        Country(code: "KH", emoji: "🇰🇭"), // Cambodia
        Country(code: "CA", emoji: "🇨🇦"),
        Country(code: "KY", emoji: "🇰🇾"), // Cayman Islands
        Country(code: "CF", emoji: "🇨🇫"),
        Country(code: "TD", emoji: "🇹🇩"), // Chad
        Country(code: "CL", emoji: "🇨🇱"),
        Country(code: "CN", emoji: "🇨🇳"),
        Country(code: "CO", emoji: "🇨🇴"),
        Country(code: "KM", emoji: "🇰🇲"), // Comoros
        Country(code: "CD", emoji: "🇨🇩"),
        Country(code: "CG", emoji: "🇨🇬"),
        Country(code: "CR", emoji: "🇨🇷"),
        Country(code: "HR", emoji: "🇭🇷"), // Croatia
        Country(code: "CU", emoji: "🇨🇺"),
        Country(code: "CW", emoji: "🇨🇼"),
        Country(code: "CY", emoji: "🇨🇾"),
        Country(code: "CZ", emoji: "🇨🇿"),

        // D
        Country(code: "DK", emoji: "🇩🇰"),
        Country(code: "DJ", emoji: "🇩🇯"),
        Country(code: "DM", emoji: "🇩🇲"),
        Country(code: "DO", emoji: "🇩🇴"),

        // E
        Country(code: "EC", emoji: "🇪🇨"),
        Country(code: "EG", emoji: "🇪🇬"),
        Country(code: "SV", emoji: "🇸🇻"), // El Salvador
        Country(code: "GQ", emoji: "🇬🇶"), // Equitorial Guinea
        Country(code: "ER", emoji: "🇪🇷"),
        Country(code: "EE", emoji: "🇪🇪"),
        Country(code: "ET", emoji: "🇪🇹"),

        // F
        Country(code: "FJ", emoji: "🇫🇯"),
        Country(code: "FI", emoji: "🇫🇮"),
        Country(code: "FR", emoji: "🇫🇷"),

        // G
        Country(code: "GA", emoji: "🇬🇦"),
        Country(code: "GM", emoji: "🇬🇲"),
        Country(code: "GE", emoji: "🇬🇪"),
        Country(code: "DE", emoji: "🇩🇪"),
        Country(code: "GH", emoji: "🇬🇭"),
        Country(code: "GR", emoji: "🇬🇷"),
        Country(code: "GD", emoji: "🇬🇩"),
        Country(code: "GU", emoji: "🇬🇺"),
        Country(code: "GT", emoji: "🇬🇹"),
        Country(code: "GG", emoji: "🇬🇬"),
        Country(code: "GN", emoji: "🇬🇳"),
        Country(code: "GW", emoji: "🇬🇼"),
        Country(code: "GY", emoji: "🇬🇾"),

        // H
        Country(code: "HT", emoji: "🇭🇹"),
        Country(code: "HN", emoji: "🇭🇳"),
        Country(code: "HK", emoji: "🇭🇰"),
        Country(code: "HU", emoji: "🇭🇺"),

        // I
        Country(code: "IS", emoji: "🇮🇸"),
        Country(code: "IN", emoji: "🇮🇳"),
        Country(code: "ID", emoji: "🇮🇩"),
        Country(code: "IR", emoji: "🇮🇷"),
        Country(code: "IQ", emoji: "🇮🇶"),
        Country(code: "IE", emoji: "🇮🇪"),
        Country(code: "IM", emoji: "🇮🇲"),
        Country(code: "IL", emoji: "🇮🇱"),
        Country(code: "IT", emoji: "🇮🇹"),

        // J
        Country(code: "JM", emoji: "🇯🇲"),
        Country(code: "JP", emoji: "🇯🇵"),
        Country(code: "JE", emoji: "🇯🇪"),
        Country(code: "JO", emoji: "🇯🇴"),

        // K
        Country(code: "KZ", emoji: "🇰🇿"),
        Country(code: "KE", emoji: "🇰🇪"),
        Country(code: "KI", emoji: "🇰🇮"),
        Country(code: "KW", emoji: "🇰🇼"),
        Country(code: "KG", emoji: "🇰🇬"),

        // L
        Country(code: "LA", emoji: "🇱🇦"),
        Country(code: "LV", emoji: "🇱🇻"),
        Country(code: "LB", emoji: "🇱🇧"),
        Country(code: "LS", emoji: "🇱🇸"),
        Country(code: "LR", emoji: "🇱🇷"),
        Country(code: "LY", emoji: "🇱🇾"),
        Country(code: "LI", emoji: "🇱🇮"),
        Country(code: "LT", emoji: "🇱🇹"),
        Country(code: "LU", emoji: "🇱🇺"),

        // M
        Country(code: "MO", emoji: "🇲🇴"),
        Country(code: "MK", emoji: "🇲🇰"),
        Country(code: "MG", emoji: "🇲🇬"),
        Country(code: "MW", emoji: "🇲🇼"),
        Country(code: "MY", emoji: "🇲🇾"),
        Country(code: "MV", emoji: "🇲🇻"),
        Country(code: "ML", emoji: "🇲🇱"),
        Country(code: "MT", emoji: "🇲🇹"),
        Country(code: "MH", emoji: "🇲🇭"),
        Country(code: "MQ", emoji: "🇲🇶"),
        Country(code: "MR", emoji: "🇲🇷"),
        Country(code: "MU", emoji: "🇲🇺"),
        Country(code: "YT", emoji: "🇾🇹"), // Mayotte
        Country(code: "MX", emoji: "🇲🇽"),
        Country(code: "FM", emoji: "🇫🇲"), // Micronesia
        Country(code: "MD", emoji: "🇲🇩"),
        Country(code: "MC", emoji: "🇲🇨"),
        Country(code: "MN", emoji: "🇲🇳"),
        Country(code: "ME", emoji: "🇲🇪"),
        Country(code: "MS", emoji: "🇲🇸"),
        Country(code: "MA", emoji: "🇲🇦"),
        Country(code: "MZ", emoji: "🇲🇿"),
        Country(code: "MM", emoji: "🇲🇲"),

        // N
        Country(code: "NA", emoji: "🇳🇦"),
        Country(code: "NR", emoji: "🇳🇷"),
        Country(code: "NP", emoji: "🇳🇵"),
        Country(code: "NL", emoji: "🇳🇱"),
        Country(code: "NC", emoji: "🇳🇨"),
        Country(code: "NZ", emoji: "🇳🇿"),
        Country(code: "NI", emoji: "🇳🇮"),
        Country(code: "NE", emoji: "🇳🇪"),
        Country(code: "NG", emoji: "🇳🇬"),
        Country(code: "NU", emoji: "🇳🇺"),
        Country(code: "NF", emoji: "🇳🇫"),
        Country(code: "KP", emoji: "🇰🇵"), // North Korea
        Country(code: "MP", emoji: "🇲🇵"), // Northern Mariana Islands
        Country(code: "NO", emoji: "🇳🇴"),

        // O
        Country(code: "OM", emoji: "🇴🇲"),

        // P
        Country(code: "PK", emoji: "🇵🇰"),
        Country(code: "PW", emoji: "🇵🇼"),
        Country(code: "PS", emoji: "🇵🇸"),
        Country(code: "PA", emoji: "🇵🇦"),
        Country(code: "PG", emoji: "🇵🇬"),
        Country(code: "PY", emoji: "🇵🇾"),
        Country(code: "PE", emoji: "🇵🇪"),
        Country(code: "PH", emoji: "🇵🇭"),
        Country(code: "PN", emoji: "🇵🇳"),
        Country(code: "PL", emoji: "🇵🇱"),
        Country(code: "PT", emoji: "🇵🇹"),
        Country(code: "PR", emoji: "🇵🇷"),
        Country(code: "QA", emoji: "🇶🇦"), // Qatar

        // R
        Country(code: "RO", emoji: "🇷🇴"),
        Country(code: "RU", emoji: "🇷🇺"),
        Country(code: "RW", emoji: "🇷🇼"),
        Country(code: "RE", emoji: "🇷🇪"),

        // S
        Country(code: "WS", emoji: "🇼🇸"), // Samoa
        Country(code: "SM", emoji: "🇸🇲"),
        Country(code: "ST", emoji: "🇸🇹"),
        Country(code: "SA", emoji: "🇸🇦"),
        Country(code: "SN", emoji: "🇸🇳"),
        Country(code: "RS", emoji: "🇷🇸"), // Serbia
        Country(code: "SC", emoji: "🇸🇨"),
        Country(code: "SL", emoji: "🇸🇱"),
        Country(code: "SG", emoji: "🇸🇬"),
        Country(code: "SX", emoji: "🇸🇽"),
        Country(code: "SK", emoji: "🇸🇰"),
        Country(code: "SI", emoji: "🇸🇮"),
        Country(code: "SB", emoji: "🇸🇧"),
        Country(code: "SO", emoji: "🇸🇴"),
        Country(code: "ZA", emoji: "🇿🇦"),
        Country(code: "GS", emoji: "🇬🇸"), // South Georgia & Sandwich
        Country(code: "KR", emoji: "🇰🇷"), // South Korea
        Country(code: "SS", emoji: "🇸🇸"),
        Country(code: "ES", emoji: "🇪🇸"), // Spain
        Country(code: "LK", emoji: "🇱🇰"), // Sri Lanka
        Country(code: "SD", emoji: "🇸🇩"),
        Country(code: "SR", emoji: "🇸🇷"),
        Country(code: "SZ", emoji: "🇸🇿"), // Eswatini
        Country(code: "SE", emoji: "🇸🇪"),
        Country(code: "CH", emoji: "🇨🇭"), // Switzerland
        Country(code: "SY", emoji: "🇸🇾"),

        // T
        Country(code: "TW", emoji: "🇹🇼"),
        Country(code: "TJ", emoji: "🇹🇯"),
        Country(code: "TZ", emoji: "🇹🇿"),
        Country(code: "TH", emoji: "🇹🇭"),
        Country(code: "TL", emoji: "🇹🇱"), // Timor-Leste
        Country(code: "TG", emoji: "🇹🇬"),
        Country(code: "TK", emoji: "🇹🇰"),
        Country(code: "TO", emoji: "🇹🇴"),
        Country(code: "TT", emoji: "🇹🇹"),
        Country(code: "TN", emoji: "🇹🇳"),
        Country(code: "TR", emoji: "🇹🇷"),
        Country(code: "TM", emoji: "🇹🇲"),
        Country(code: "TV", emoji: "🇹🇻"),

        // U
        Country(code: "UG", emoji: "🇺🇬"),
        Country(code: "UA", emoji: "🇺🇦"),
        Country(code: "AE", emoji: "🇦🇪"), // United Arab Emirates
        Country(code: "GB", emoji: "🇬🇧"), // United Kingdon
        Country(code: "US", emoji: "🇺🇸"),
        Country(code: "UY", emoji: "🇺🇾"),
        Country(code: "UZ", emoji: "🇺🇿"),

        // V
        Country(code: "VU", emoji: "🇻🇺"),
        Country(code: "VA", emoji: "🇻🇦"),
        Country(code: "VE", emoji: "🇻🇪"),
        Country(code: "VN", emoji: "🇻🇳"),

        // W
        Country(code: "WF", emoji: "🇼🇫"),
        Country(code: "EH", emoji: "🇪🇭"), // Western Sahara

        // Y
        Country(code: "YE", emoji: "🇾🇪"),

        // Z
        Country(code: "ZM", emoji: "🇿🇲"),
        Country(code: "ZW", emoji: "🇿🇼")
    ]
    
    var body: some View {
        let minDimension = min(self.screenHeight, self.screenWidth)
        VStack(spacing: 10) {
            
            if authViewModel.isLoggedIn { //LOGGED IN!
                
                // MARK: Profile Pic
                if let theProfileImageURL = authViewModel.profileImageURL {
                    AsyncImage(url: theProfileImageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 100, height: 100)
                            .padding(.bottom)
                    } placeholder: {
                        //ProgressView() // loading spinner while the image loads
                    }
                    
                } else if let gcImage = gameCenterImage {
                    Image(uiImage: gcImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                        .padding(.bottom)
                }
                
                // MARK: Display Name
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
                                .font(.system(size: minDimension / 20, weight: .bold, design: .serif))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                newDisplayName = "" //authViewModel.displayName // Load current username for editing
                                isEditing = true // Enter editing mode
                                focus = .displayName
                            }) {
                                Image(systemName: "pencil")
                                    .font(.headline)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
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
                
                // MARK: Country Selection
                HStack {
                    Text("Representing:")
                        //.font(.title)
                        .font(.system(size: minDimension / 20, weight: .bold, design: .serif))
                    
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(
                            countries.sorted(by: { $0.localizedName < $1.localizedName }),
                            id: \.self
                        ) { country in
                            Text("\(country.emoji) \(country.localizedName)")
                                .tag(country as Country?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onAppear {
                        loadSelectedCountry()} // load the selected country when the view appears
                    .onChange(of: selectedCountry) {
                        // update memory:
                        authViewModel.userCountry = selectedCountry!.code
                        // update server storage:
                        authViewModel.updateUserCountryInFirestore(country: selectedCountry!.code)
                        // update local long-term storage:
                        UserDefaults.standard.set(selectedCountry?.code, forKey: "country")
                    }
                }
                
                // MARK: ELO Rating
                Text("Hex Chess Elo Rating:  \(authViewModel.eloScore)") //could be modified to use a local toggle that shows if its been updated, preventing the server call EVERY profile view, but we can implement that later
                    .font(.system(size: minDimension / 20, weight: .bold, design: .serif))
                    .onAppear {
                        // when the view appears, fetch elo (we already have a function for this in multiplayerManager)
                        MultiplayerManager.shared.fetchElo(forUserId: MultiplayerManager.shared.currentUserId) { elo in
                            authViewModel.eloScore = elo ?? 1000
                        }
                    }
                
                // MARK: Sign Out Button / Delete Account Button
                HStack(spacing: 20) {
                    Button(action: authViewModel.signOut) { //maybe make this smaller?
                        Text("Sign Out")
                            .font(.system(size: minDimension / 24, weight: .bold, design: .serif))
                            .underline()
                            .padding(5)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.red)
                    }
                    
                    Button(action: {showDeleteConfirmation = true}) {
                        Text("Delete Account")
                            .font(.system(size: minDimension / 24, weight: .bold, design: .serif))
                            .underline()
                            .padding(5)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.red)
                    }
                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                authViewModel.deleteUserAndData()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Divider()
                    .padding(5)
                
                VStack(spacing: 20) {
                    if !isKeyboardVisible {
                        
                        // MARK: - Achievements section
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                                .foregroundColor(Color.accentColor)
                            
                            Text("Achievements")
                                .font(.system(size: minDimension / 18, weight: .bold, design: .serif))
                        }
                        
                        ScrollView {
                            VStack {
                                ForEach(AchievementManager.shared.achievements) { achievement in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(achievement.title)
                                                .font(.system(size: minDimension / 20, weight: .bold, design: .serif))
                                            
                                            Text(achievement.description)
                                                .font(.body)
                                                .padding(.bottom, 8)
                                        }
                                        
                                        Spacer()
                                        
                                        // Show a filled star if unlocked, otherwise an empty star
                                        Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.title2)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                .onAppear { //if the keyboard is on screen, hide achievement section
                    AchievementManager.shared.loadUserAchievements()
                    
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

                
// MARK: - SIGN IN SCREEN
                
            } else { //NOT LOGGED IN

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
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
                    Button(action: {
                        authViewModel.sendPasswordReset(email: authViewModel.email)
                    }) {
                        Text(resetPasswordTextAppend())
                            .padding()
                            .foregroundColor(.red)
                    }
                    
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
                .padding(.bottom, 10)
                
                // Sign in with Google
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
                .padding(.vertical, 10)
                .buttonStyle(.bordered)
                
                // Sign in with Apple
                SignInWithAppleButton { request in
                    authViewModel.signInWithAppleRequest(request)
                } onCompletion: { result in
                    authViewModel.signInWithAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .id(colorScheme) //this forces swiftui to switch the button color scheme when the user changes the scheme
                .frame(height: 50)
                .cornerRadius(8)
            }
        }
        .onAppear {
            GameCenterManager.shared.loadGameCenterProfileImage { image in
                DispatchQueue.main.async { // remember to switch to the main thread before updating SwiftUI state
                    self.gameCenterImage = image
                }
            }
        }
        .padding()
    }
    
    func loadSelectedCountry() {
        // try loading the ISO code from UserDefaults
        if let savedCountryCode = UserDefaults.standard.string(forKey: "country"),
           let matchingCountry = countries.first(where: { $0.code == savedCountryCode }) {
            // found a valid country in local storage, assign it
            self.selectedCountry = matchingCountry
        }

        // regardless, also attempt to load the latest code from Firestore
        authViewModel.loadUserCountryFromFirestore { loadedCode in
            // if Firestore returns a valid code that we have in our array, update
            if let loadedCode = loadedCode,
               let matchingCountry = self.countries.first(where: { $0.code == loadedCode }) {
                self.selectedCountry = matchingCountry
            }
        }
    }
    
    private func resetPasswordTextAppend() -> AttributedString {
        var attributedString = AttributedString(authViewModel.errorMessage)
        
        if authViewModel.errorMessage == "The email address is already in use by another account." {
            attributedString += AttributedString(" Reset Password?")
            
            // Apply underline to "Reset Password?"
            if let range = attributedString.range(of: "Reset Password?") {
                attributedString[range].underlineStyle = .single
            }
        } else { authViewModel.errorMessage = ""
        }
            
        
        return attributedString
    }
}



//can remove for production:
//#Preview {
    //ProfileView(screenHeight: 720, screenWidth: 200) //??????
//}
