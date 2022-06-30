//
//  ContentView.swift
//  PropertyWrappers
//
//  Created by Victor Roldan on 26/06/22.
//

import SwiftUI
struct PostModel : Decodable{
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class PostViewModel: ObservableObject{
    @Published var postList = [PostModel]()
    
    func initialize() async{
        print("initialize...")
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else{
            return
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            if let response = try? JSONDecoder().decode([PostModel].self, from: data){
                DispatchQueue.main.async {
                    self.postList = response
                }
            }

        }catch{
            print("error: ", error)
        }
    }
}


struct ContentView: View {
    @State private var following : Bool = false
    @StateObject var viewModel = PostViewModel()
    
    var body: some View {
        VStack{
            HeaderView(following: $following)
                .environmentObject(viewModel)
            PostsListView(viewModel: viewModel)
        }
    }
}

struct PostsListView: View {
    @StateObject var viewModel : PostViewModel
    
    var body: some View {
        List{
            ForEach(viewModel.postList, id: \.id){ post in
                VStack(alignment: .leading){
                    Text(post.title).bold()
                    Text(post.body).font(.caption)
                }
            }.onDelete { index in
                viewModel.postList.remove(atOffsets: index)
            }
        }.onAppear {
            Task{
                await viewModel.initialize()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HeaderView: View {
    @Binding var following : Bool
    
    var body: some View {
        VStack(spacing: 10){
            HStack{
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                Spacer()
            }
            Text("Victor Roldan Dev").font(.callout)
            Button {
                //do something
                following = !following
            } label: {
                if following{
                    Text("Unfollow")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 20)
                        .background(.gray.opacity(0.2))
                        .foregroundColor(.black.opacity(0.5))
                        .bold()
                        .cornerRadius(20)
                }else{
                    Text("Follow")
                        .padding(.vertical, 5)
                        .padding(.horizontal, 20)
                        .background(.blue)
                        .foregroundColor(.white)
                        .bold()
                        .cornerRadius(20)
                }
                
            }
            CounterView()
                .background(.red)
        }
    }
}

struct CounterView : View{
    @EnvironmentObject var viewModel : PostViewModel
    
    var body: some View{
        Text("count: \(viewModel.postList.count)")
    }
}
