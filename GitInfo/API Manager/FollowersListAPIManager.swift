//
//  FollowersListAPIManager.swift
//  GitInfo
//
//  Created by Srijan Kumar  on 03/09/22.
//

import UIKit

class FollowersListAPIManager: UIViewController {
    var dataPassingThroughClosure: (([UserInfo]?) -> Void)?
    func fetchFollowerInfo(userName: String, pageNumber: Int)
    {
        let urlString = "https://api.github.com/users/\(userName)/followers?per_page=100&page=\(pageNumber)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String)
    {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){
                [weak self] (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let safeData = data{
                    print("URL: \(urlString) succesful, withData: \(safeData)")
                    if let fetchedData = self?.parseJSON(safeData){
                        self?.dataPassingThroughClosure?(fetchedData)
                    }
                }
            }
            task.resume()
        } else {
            print("Failed to parse URL String: \(urlString)")
        }
    }
    
    func parseJSON(_ productData: Data) -> [UserInfo]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([UserInfo].self, from: productData)
            return decodedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
