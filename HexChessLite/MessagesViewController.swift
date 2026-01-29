//
//  MessagesViewController.swift
//  HexChessLite
//
//  Created by Sawyer Christensen on 8/23/25.
//

import UIKit
import Messages
import SwiftUI
import SpriteKit

//notes: there should be two game-creating menus, compact, and expanded for ipad
//the device should be defaulting to these two menus if it is not continuing a game save (from opening a bubble)

//project-wide variables:
weak var currentGameScene: MessagesGameScene?

enum PlayerColor: String {
    case white, black }
var localPlayerColor: PlayerColor?
var blackPlayerID: String?

var isGameOver: Bool = false //not used yet

var latestHexPGN: [UInt8]? {
    didSet {
        guard latestHexPGN != oldValue else { return } //oldValue is a value provided by Swift
        if let scene = currentGameScene, let hexPgn = latestHexPGN { //if scene already valid, animate the new move immediately
            Task {
                await scene.animateMove(hexPgn: hexPgn)
            }
        }
    }
}

class MessagesViewController: MSMessagesAppViewController {
    
    private var menuViewModel: MenuViewModel?
    private var activeGamePGN: [UInt8]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {
        //print("willBecomeActive")
        super.willBecomeActive(with: conversation)
        
        if let selectedMessage = conversation.selectedMessage,
           let moves = decodeMoves(from: selectedMessage, in: conversation) {
            // A message bubble was tapped
            latestHexPGN = moves
        } else {
            // The app was opened from the app drawer
            latestHexPGN = nil
        }
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) { //note: we need to make sure that this does NOT fire when the message is sent, it could result in applyHexPGN being called after the most recent move, which shouldnt happen
        //this is for when you tap on a sent game bubble when the menu is open
        //print("didSelect")
        guard let moves = decodeMoves(from: message, in: conversation) else { return }
        latestHexPGN = moves
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        //print("willTransition")
        super.willTransition(to: presentationStyle)
        guard let conversation = activeConversation else { return }

        // The menu is compact (iPhone), we do not have a game loaded, so the user is expanding the menu
        if latestHexPGN == nil && children.first is UIHostingController<MessagesMainMenuView> {
            withAnimation(.easeInOut(duration: 0.3)) {
                menuViewModel?.presentationStyle = presentationStyle }
            return //exit early to skip presenting the menu view again later. we want a transition!
        }
        
        if presentationStyle == .expanded && latestHexPGN != nil {
            presentGameController() //there is a game loaded, and we're switching to game view
        } else { //there is either no game loaded, or we are switching to the compact view
            presentMenuController(for: presentationStyle, with: conversation)
        }
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        //print("didReceive")
        guard let moves = decodeMoves(from: message, in: conversation) else { return }
        latestHexPGN = moves
    }
    
    // MARK: - Helper functions
    private func presentMenuController(for presentationStyle: MSMessagesAppPresentationStyle, with conversation: MSConversation) {
        let viewModel = MenuViewModel(presentationStyle: presentationStyle)
        self.menuViewModel = viewModel
        
        let menuView = MessagesMainMenuView(viewModel: viewModel) { [weak self] in
            self?.createGame(conversation: conversation)
        }
                
        presentView(UIHostingController(rootView: menuView))
    }
    
    private func presentGameController() {
        //print("presentGameController")
        //removeAllChildViewControllers()
        let gameView = MessagesGameView(delegate: self)
        let gameController = UIHostingController(rootView: gameView)
        
        presentView(gameController)
    }
    
    private func presentView(_ viewController: UIViewController) {
        //dismiss any pop-up (like the promotion window) that might be open
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            
            //remove all existing child view controllers
            for child in self.children {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
            
            //add the new view controller
            self.addChild(viewController)
            viewController.view.frame = self.view.bounds
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(viewController.view)
            
            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            
            viewController.didMove(toParent: self)
        }
    }
    
    private func removeAllChildViewControllers() {
        //print("cleaning scene...")
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    //when the user presses "start game" from main menu, create a game state and load it into the chat
    private func createGame(conversation: MSConversation) {
        //print("createGame")
        let session = MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
    
        if let boardImage = UIImage(named: "iMessageGameInvite") {
            layout.image = boardImage
        }
        layout.caption = NSLocalizedString("Let's Play Hex Chess!", comment: "iMessage layout text")
        message.layout = layout
        message.summaryText = NSLocalizedString("Let's Play Hex Chess!", comment: "1st iMessage summary text")
        
        let hexPgn: [UInt8] = []
        let hexPgnData = Data(hexPgn)
        let hexPgnString = hexPgnData.base64EncodedString()
        
        let blackID = conversation.localParticipantIdentifier.uuidString

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "hexPgn", value: hexPgnString),
            URLQueryItem(name: "blackPlayerID", value: blackID)
        ]
        message.url = components.url
       
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error.localizedDescription)")
            }
        }
    }
    
    private func decodeMoves(from message: MSMessage, in conversation: MSConversation) -> [UInt8]? { //also assigns local player color!
        guard let url = message.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let hexPgnString = components.queryItems?.first(where: { $0.name == "hexPgn" })?.value,
              let data = Data(base64Encoded: hexPgnString)
        else {
            print("⚠️ Failed to decode HexPgn from message.")
            return nil
        }
        
        if blackPlayerID == nil {
            if let blackIDFromMessage = components.queryItems?.first(where: { $0.name == "blackPlayerID" })?.value {
                blackPlayerID = blackIDFromMessage
            }
        }
        
        let myID = conversation.localParticipantIdentifier.uuidString
        localPlayerColor = (myID == blackPlayerID) ? .black : .white

        let hexPgn = [UInt8](data) // convert Data to [UInt8]
        return hexPgn
    }
}

extension MessagesViewController: GameSceneDelegate {
    func autoSend(_ scene: MessagesGameScene, updatedHexPGN hexPgn: [UInt8],currentTurn: String) {
        //print("autoSend move")
        let message = encodeMoves(hexPgn: hexPgn, currentTurn: currentTurn)

        activeConversation?.send(message, completionHandler: { error in
            if let error = error {
                print("Failed to send move: \(error)")
            }
        })
    }
    
    private func encodeMoves(hexPgn: [UInt8], currentTurn: String) -> MSMessage {//we could also make it so that currentTurn does not have to be passed in, and we instead read who the current player is by their IDs, but this works as well
        let session = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)
        let layout = MSMessageTemplateLayout()
        
        if !isGameOver { //game is not over. it is somebody's turn
            if currentTurn == "white" {
                layout.image = UIImage(named: "whiteToMove")
                layout.caption = NSLocalizedString("Hex Chess – white's turn!", comment: "iMessage caption")
            } else { //black to move
                layout.image = UIImage(named: "blackToMove")
                layout.caption = NSLocalizedString("Hex Chess – black's turn!", comment: "iMessage caption")
            }
            
            
        } else { //game over! somebody won!
            if currentTurn == "white" { //because black won last turn
                layout.image = UIImage(named: "blackWon")
            } else {
                layout.image = UIImage(named: "whiteWon")
            }
            layout.caption = NSLocalizedString("I won in Hex Chess!", comment: "iMessage caption")
        }
        
        message.layout = layout
        message.summaryText = NSLocalizedString("Hex Chess", comment: "")
        
        //encoding HexPGN...
        let hexPgnData = Data(hexPgn)
        let hexPgnString = hexPgnData.base64EncodedString()

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "hexPgn", value: hexPgnString),
            URLQueryItem(name: "blackPlayerID", value: blackPlayerID)
        ]
        message.url = components.url

        return message
    }
    
    func requestRematch() {
        guard let conversation = activeConversation else { return }
        createGame(conversation: conversation)
        self.dismiss()
        removeAllChildViewControllers()
        self.requestPresentationStyle(.compact)
    }
}
