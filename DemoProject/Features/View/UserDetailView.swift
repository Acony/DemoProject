//
//  UserDetailView.swift
//  test1
//
//
import SwiftUI

struct UserDetailView: View {
    let user: GitHubUser
    
    @StateObject private var viewModel = GithubUserDetailViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    // Computed properties for user details
    private var username: String { viewModel.userDetail?.login ?? user.login }
    private var avatarUrl: URL? { URL(string: viewModel.userDetail?.avatarUrl ?? user.avatarUrl) }
    private var location: String { viewModel.userDetail?.location ?? "" }
    private var followers: Int { viewModel.userDetail?.followers ?? 0 }
    private var following: Int { viewModel.userDetail?.following ?? 0 }
    private var htmlUrl: String { viewModel.userDetail?.htmlUrl ?? user.htmlUrl }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                UserInfoCard(username: username, avatarUrl: avatarUrl, location: location)
                UserStatsView(followers: followers, following: following)
                BlogSection(htmlUrl: htmlUrl)

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUserDetail(from: user.login)
            }
        }
    }
}

// MARK: - Subviews

private struct UserInfoCard: View {
    let username: String
    let avatarUrl: URL?
    let location: String
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                
                if let avatarUrl = avatarUrl {
                    RemoteImage(source: avatarUrl)
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                        .cornerRadius(35)
                } else {
                    Image(systemName: "person.circle.fil")
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.red)
                        .cornerRadius(35)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.gray)
                    Text(location.isEmpty ? "Unknown" : location)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

private struct UserStatsView: View {
    let followers: Int
    let following: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            StatView(icon: "person.2.fill", value: "\(followers)+", label: "Follower")
            
            Spacer()
            
            StatView(icon: "medal.fill", value: "\(following)+", label: "Following")
            
            Spacer()
        }
    }
}

private struct StatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(Color(UIColor.darkGray))
            }
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

private struct BlogSection: View {
    let htmlUrl: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Blog")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Link(htmlUrl, destination: URL(string: htmlUrl)!)
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let user = GitHubUser(
            id: 101,
            login: "jvantuyl",
            avatarUrl: "https://avatars.githubusercontent.com/u/101?v=4",
            htmlUrl: "https://github.com/jvantuyl"
        )
        UserDetailView(user: user)
    }
}
