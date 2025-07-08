//
//  UserRow.swift
//  test1
//
//  Created by Thanh Quang on 13/4/25.
//

import SwiftUI

struct UserRow: View {
    let user: GitHubUser
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Rectangle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .padding(10)
                        
                    RemoteImage(source: URL(string: user.avatarUrl)!)
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(40)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.login)
                        .font(.headline)

                    Link(user.htmlUrl, destination: URL(string: user.htmlUrl)!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
//            .padding()
            
//            Divider()
//                .padding(.leading)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    let user =  GitHubUser(id: 101,
                           login: "jvantuyl",
                           avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
                           htmlUrl: "https://github.com/jvantuyl"
                )
    UserRow(user: user)
}
