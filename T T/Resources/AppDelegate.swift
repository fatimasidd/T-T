//
//  AppDelegate.swift
//  T T
//
//  Created by Fatima Siddiqui on 30/04/1445 AH.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
 
    



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID  = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else{
            if let error = error{
                print("Failed to sign in with google:\(error)")
            }
            return
        }
        guard let user = user else{
            return
        }
        print("Did sign in with Google:\(user)")
       guard let email = user.profile.email,
             let firstName = user.profile.givenName,
             let lastName = user.profile.familyName else{
           return
       }
        
        DatabaseManager.shared.userExists(with: email, completion: {exists in
            if !exists{
                //insert to database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
            }
        })
        
        guard let authentication = user.authentication else {
            print("Missing auth object off og google user")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion:{authResult,error in
            guard authResult != nil,error == nil else{
                print("failed to login with google")
                return
            }
            print("Successfully signed in with Google credentials")
            NotificationCenter.default.post(name: .didLogInNotification,object:nil)
        })
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
        
    }
    func application(_ application:UIApplication, open url:URL,options:[UIApplication.OpenURLOptionsKey:Any]) ->Bool{
        return GIDSignIn.sharedInstance().handle(url)
    }
}

