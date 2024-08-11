//
//  HomeViewController.swift
//  Final Exam - MobileData
//
//  Created by Sunil Balami on 2024-08-11.
//
// HomeViewController.swift
import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies = [Movie]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchMovies()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc private func refreshData() {
        fetchMovies()
    }
    
    private func fetchMovies() {
        let db = Firestore.firestore()
        
        db.collection("movies").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No movies found")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
                return
            }
            
            self?.movies = documents.map { doc -> Movie in
                let data = doc.data()
                let title = data["title"] as? String ?? ""
                let rating = data["mpaRating"] as? String ?? ""
                let releaseYear = data["year"] as? String ?? ""
                let imageURL = data["imageURL"] as? String
                let studio = data["studio"] as? String ?? ""
                let genre = data["genre"] as? String ?? ""
                let directors = data["directors"] as? String ?? ""
                let actor = data["actor"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                return Movie(id: doc.documentID, title: title, rating: rating, releaseYear: releaseYear, imageURL: imageURL, studio: studio, genre: genre, directors: directors, actor: actor, description: description)
            }
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func loadImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.image = nil
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        // Display an alert to confirm logout
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        // OK action to confirm logout
        let okAction = UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        // Cancel action to dismiss the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Perform the logout process
    private func performLogout() {
        // Clear the token from Keychain
        KeychainHelper.delete(key: "userToken")
        
        // Navigate back to the login screen
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
}



// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Expected `MovieCollectionViewCell` type for reuseIdentifier movieCell. Check the configuration in storyboard.")
        }
        
        let movie = movies[indexPath.row]
        cell.titleLbl.text = movie.title
        cell.ratingLbl.text = movie.rating
        cell.releaseYearLbl.text = "\(movie.releaseYear)"
        
        loadImage(from: movie.imageURL, into: cell.imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        performSegue(withIdentifier: "showMovieDetailSegue", sender: selectedMovie)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 2
        let totalPadding = padding * (numberOfItemsPerRow + 1)
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / numberOfItemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetailSegue",
           let destinationVC = segue.destination as? MovieDetailViewController,
           let movie = sender as? Movie {
            destinationVC.movie = movie
        }
    }
    
    
}
