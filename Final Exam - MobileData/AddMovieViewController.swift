//
//  AddMovieViewController.swift
//  Final Exam - MobileData
//
//  Created by Sunil Balami on 2024-08-11.
//

// AddMovieViewController.swift
import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddMovieViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var studioTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var directorsTextField: UITextField!
    @IBOutlet weak var actorTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var mpaRatingTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    
    @IBOutlet weak var button1: UIButton!
    var selectedImage: UIImage?
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectImageButton.layer.cornerRadius = 20
        button1.layer.cornerRadius = 20
        if let movie = movie {
            titleTextField.text = movie.title
            studioTextField.text = movie.studio
            genreTextField.text = movie.genre
            directorsTextField.text = movie.directors
            actorTextField.text = movie.actor
            yearTextField.text = movie.releaseYear
            descriptionTextField.text = movie.description
            mpaRatingTextField.text = movie.rating
            // You might want to load the existing image as well
        }
    }
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let studio = studioTextField.text, !studio.isEmpty,
              let genre = genreTextField.text, !genre.isEmpty,
              let directors = directorsTextField.text, !directors.isEmpty,
              let actor = actorTextField.text, !actor.isEmpty,
              let year = yearTextField.text, !year.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty,
              let mpaRating = mpaRatingTextField.text, !mpaRating.isEmpty,
              let movieImage = selectedImage else {
            showAlert(message: "Please fill in all fields and select an image.")
            return
        }
        
        uploadImageToFirebaseStorage(image: movieImage) { [weak self] imageURL in
            guard let self = self, let imageURL = imageURL else {
                self?.showAlert(message: "Failed to upload image.")
                return
            }
            
            if let movie = self.movie {
                self.updateMovieInFirestore(movieId: movie.id, title: title, studio: studio, genre: genre, directors: directors, actor: actor, year: year, description: description, mpaRating: mpaRating, imageURL: imageURL)
            } else {
                self.addMovieToFirestore(title: title, studio: studio, genre: genre, directors: directors, actor: actor, year: year, description: description, mpaRating: mpaRating, imageURL: imageURL)
            }
        }
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("movie_images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }
    
    func addMovieToFirestore(title: String, studio: String, genre: String, directors: String, actor: String, year: String, description: String, mpaRating: String, imageURL: String) {
        let db = Firestore.firestore()
        let movieData: [String: Any] = [
            "title": title,
            "studio": studio,
            "genre": genre,
            "directors": directors,
            "actor": actor,
            "year": year,
            "description": description,
            "mpaRating": mpaRating,
            "imageURL": imageURL
        ]
        
        db.collection("movies").addDocument(data: movieData) { error in
            if let error = error {
                self.showAlert(message: "Failed to save movie: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Movie added successfully!")
                // Optionally, you can reset the form or navigate back to a previous screen
            }
        }
    }
    
    func updateMovieInFirestore(movieId: String, title: String, studio: String, genre: String, directors: String, actor: String, year: String, description: String, mpaRating: String, imageURL: String) {
        let db = Firestore.firestore()
        let movieData: [String: Any] = [
            "title": title,
            "studio": studio,
            "genre": genre,
            "directors": directors,
            "actor": actor,
            "year": year,
            "description": description,
            "mpaRating": mpaRating,
            "imageURL": imageURL
        ]
        
        db.collection("movies").document(movieId).updateData(movieData) { error in
            if let error = error {
                self.showAlert(message: "Failed to update movie: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Movie updated successfully!")
                // Optionally, navigate back or update the UI
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddMovieViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.selectedImage = selectedImage
            // Optionally, update the button or view with the selected image
            selectImageButton.setTitle("Image Selected", for: .normal)
        } else {
            print("No image was selected.")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker was cancelled.")
        dismiss(animated: true, completion: nil)
    }
}

