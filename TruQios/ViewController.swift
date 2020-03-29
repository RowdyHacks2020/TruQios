//
//  ViewController.swift
//  TruQios
//
//  Created by cory on 3/29/20.
//  Copyright © 2020 TruQ. All rights reserved.
//

import UIKit
import AWSAppSync

class Todos: UIViewController{
    // Reference AppSync client
    var appSyncClient: AWSAppSyncClient?
    var discard: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
    }

    func subscribe() {
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(), resultHandler: { (result, transaction, error) in
                if let result = result {
                    print("CreateTodo subscription data:"+result.data!.onCreateTodo!.name + " " + result.data!.onCreateTodo!.description!)
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            print("Subscribed to CreateTodo Mutations.")
            } catch {
                print("Error starting subscription.")
            }
    }
    
    func runMutation(){
        let mutationInput = CreateTodoInput(name: "Use AppSync", description:"Realtime and Offline")
        appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            print("Mutation complete.")
        }
    }
    
    /* Suggested: makes sure mutation is complete before query
     func runMutation(){
         let mutationInput = CreateTodoInput(name: "Use AppSync", description:"Realtime and Offline")
         appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)) { [weak self] (result, error) in
             // ... do whatever error checking or processing you wish here
             self?.runQuery()
         }
     }
     */
    
    func runQuery(){
        appSyncClient?.fetch(query: ListTodosQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            result?.data?.listTodos?.items!.forEach { print(($0?.name)! + " " + ($0?.description)!) }
        }
    }
    
    
}

/*


 class Todos: UIViewController{
   // Reference AppSync client
   var appSyncClient: AWSAppSyncClient?

   override func viewDidLoad() {
       super.viewDidLoad()
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       appSyncClient = appDelegate.appSyncClient
   }
 }
 
 
 Call the runMutation(), runQuery(), and subscribe() methods from your app code such as from a button click or when your app starts in viewDidLoad(). You will see data being stored and retrieved in your backend from the Xcode console.

 Testing your API You can open the AWS console for you to run Queries, Mutation, or Subscription against you new API at any time directly by running the following command:

 $ amplify console api
 > GraphQL               ##Select GraphQL
 This will open the AWS AppSync console for you to run Queries, Mutations, or Subscriptions at the server and see the changes in your client app.
 */
