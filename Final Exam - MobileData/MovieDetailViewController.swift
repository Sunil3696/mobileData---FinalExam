//
//  MovieDetailViewController.swift
//  Final Exam - MobileData
//
//  Created by Sunil Balami on 2024-08-11.
//
// MovieDetailViewController.swift
import UIKit
import FirebaseFirestore
import FirebaseStorage

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var studioLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var directorsLbl: UILabel!
    @IBOutlet weak var actorLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mpaRatingLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var editbutton: UIButton!
    
    
    
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editbutton.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 10
        genreLbl.layer.cornerRadius = 20
        if let movie = movie {
            titleLbl.text = movie.title
            studioLbl.text = movie.studio
            genreLbl.text = movie.genre
            directorsLbl.text = movie.directors
            actorLbl.text = movie.actor
            yearLbl.text = movie.releaseYear
            descriptionLbl.text = movie.description
            mpaRatingLbl.text = movie.rating
            
            loadImage(from: movie.imageURL)
        }
    }
    
    private func loadImage(from urlString: String?) {
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
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "editMovieSegue", sender: movie)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMovieSegue",
           let destinationVC = segue.destination as? AddMovieViewController,
           let movie = sender as? Movie {
            destinationVC.movie = movie
        }
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
               
               // Show confirmation alert
               let alert = UIAlertController(title: "Delete Movie", message: "Are you sure you want to delete this movie?", preferredStyle: .alert)
               
               alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
               
               alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                   self.deleteMovie(movie: movie)
               })
               
               present(alert, animated: true, completion: nil)
           }
           
           private func deleteMovie(movie: Movie) {
               let db = Firestore.firestore()
               db.collection("movies").document(movie.id).delete { error in
                   if let error = error {
                       self.showAlert(message: "Failed to delete movie: \(error.localizedDescription)")
                   } else {
                       self.showAlert(message: "Movie deleted successfully!") {
                           // Optionally, navigate back to the previous screen
                           self.navigationController?.popViewController(animated: true)
                       }
                   }
               }
           }
           
           func showAlert(message: String, completion: (() -> Void)? = nil) {
               let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                   completion?()
               }))
               self.present(alert, animated: true, completion: nil)
           }
       }
