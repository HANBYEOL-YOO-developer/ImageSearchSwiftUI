//
//  ContentView.swift
//  ImageSearchSwiftUI
//
//  Created by APPLE on 2020/10/12.
//

import SwiftUI
import KingfisherSwiftUI

struct RSS: Decodable {
    let meta: Meta
    let documents: [Document]
}

struct Meta: Codable {
    var total_count: Int
    var pageable_count: Int
    var is_end: Bool
}

struct Document: Codable, Hashable {
    var thumbnail_url: String
    var image_url: String
    var display_sitename: String
    var datetime: String
}

class GridViewModel: ObservableObject {

    @Published var documents = [Document]()
    var meta = Meta(total_count: 0, pageable_count: 0, is_end: true)
    @Published var alert = false
    var imageCount = 0      // collectionview에서 보여지고 있는 이미지 수
    var currentPage = 1     // 다음 검색 API request 페이지 번호, 1~50 사이의 값

    var workItem = DispatchWorkItem { }

    var textForSearch = "" {
        didSet {
            // 초기화
            meta.is_end = false
            documents = []
            imageCount = 0
            currentPage = 1
            workItem.cancel()

            workItem = DispatchWorkItem {
                self.loadData()
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
        }
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        guard let url = URL(string: "https://dapi.kakao.com/v2/search/image?query=\(textForSearch)&page=\(currentPage)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK 2962a9faf8ec4f7260cf341077c60ed2", forHTTPHeaderField: "authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                if self.currentPage == 1 {
                    DispatchQueue.main.async {
                        self.documents = rss.documents
                    }
                } else {
                    DispatchQueue.main.async  {
                        self.documents.append(contentsOf: rss.documents)
                    }
                }
                DispatchQueue.main.async {
                    self.meta = rss.meta
                }
                if rss.documents.count == 0 {
                    DispatchQueue.main.async {
                        self.alert = true
                    }
                }
            } catch {
                print("Failed to decode: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ContentView: View {
    @ObservedObject var vm = GridViewModel()

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer(minLength: 8)
                    Color.init(red: 0.93, green: 0.93, blue: 0.93)
                        .frame(height: 35)
                        .cornerRadius(10)
                    Spacer(minLength: 8)
                }
                HStack {
                    Spacer(minLength: 16).layoutPriority(900)
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    Spacer().layoutPriority(1000)
                }
                HStack {
                    Spacer(minLength: 36)
                    TextField("이미지 검색", text: $vm.textForSearch)
                    Spacer(minLength: 20)
                }
            }
            .frame(height: 56)
            .border(Color.init(red: 0.85, green: 0.85, blue: 0.85), width: 0.5)
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 100, maximum: 200)),
                    GridItem(.flexible(minimum: 100, maximum: 200)),
                    GridItem(.flexible(minimum: 100, maximum: 200))
                ], alignment: .leading, spacing: 0, content: {
                    ForEach(vm.documents, id: \.self) { document in
                        DocumentRow(document: document)
                            .onAppear {
                                if document == self.vm.documents.last {
                                    scrollDidEnd()
                                }
                            }
                    }
                })
            }
        }.alert(isPresented: $vm.alert, content: {
            Alert(title: Text("알림"), message: Text("검색 결과가 없습니다."), dismissButton: nil)
        })
    }
    
    func scrollDidEnd() {
            switch vm.documents.count - vm.imageCount {
            case 31...:
                vm.imageCount += 30
                if !vm.meta.is_end {     // data fetch (버퍼를 두기 위해 미리 불러옴)
                    vm.currentPage += 1
                    vm.loadData()
                }
            default:
                vm.imageCount = vm.documents.count
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
