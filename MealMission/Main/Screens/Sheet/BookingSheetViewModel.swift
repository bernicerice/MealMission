import SwiftUI
import Combine
import FirebaseAuth
import FirebaseDatabase

// MARK: - Main Actor
@MainActor
final class BookingSheetViewModel: ObservableObject {
    
    // MARK: - Properties
    let restaurant: Restaurant
    let mode: TargetMode
    
    // MARK: - Callbacks
    private var onDismiss: (() -> Void)?
    private var onBookingSuccess: ((String) -> Void)?
    
    // MARK: - Published Properties
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var customerPlaces: Int = 1
    
    // MARK: - Initializer
    init(restaurant: Restaurant, 
         mode: TargetMode, 
         onDismiss: (() -> Void)? = nil, 
         onBookingSuccess: ((String) -> Void)? = nil) {
        self.restaurant = restaurant
        self.mode = mode
        self.onDismiss = onDismiss
        self.onBookingSuccess = onBookingSuccess
    }
    
    // MARK: - Computed Properties (Formatted Strings)
    var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }
    
    var selectedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
    
    // MARK: - Computed Properties (Restaurant Data)
    var placeImageName: String { restaurant.imageURL }
    var placeName: String { restaurant.name }
    var workingHours: String { restaurant.timeRange }
    var rating: String { String(restaurant.likesCount) }
    
    // MARK: - Computed Properties (UI Logic)
    
    var showBookingControls: Bool {
        mode == .can
    }
    
    var titleText: String {
        mode == .can ? "Booking" : "You can come in a restaurant's working time and get food for free"
    }
    
    var actionButtonTitle: String {
        mode == .can ? "BOOK NOW" : "THANK YOU!"
    }
    
    // MARK: - Actions
    func incrementPlaces() {
        customerPlaces += 1
    }
    
    func decrementPlaces() {
        if customerPlaces > 1 {
            customerPlaces -= 1
        }
    }
    
    func primaryAction() {
        if mode == .can {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: User not logged in.")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: selectedDate)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: selectedTime)

            let bookingData: [String: Any] = [
                "restaurantId": restaurant.id,
                "date": DateFormatter.localizedString(from: selectedDate, dateStyle: .short, timeStyle: .none),
                "time": DateFormatter.localizedString(from: selectedTime, dateStyle: .none, timeStyle: .short),
                "numberOfPeople": customerPlaces,
                "createdAt": ServerValue.timestamp()
            ]

            let dbRef = Database.database().reference()
            let userBookingsRef = dbRef.child("bookings").child(userId).childByAutoId()
            
            print("Saving booking to path: \(userBookingsRef.url)")
            userBookingsRef.setValue(bookingData) { error, ref in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving booking: \(error.localizedDescription)")
                    } else {
                        print("Booking saved successfully for restaurant ID: \(self.restaurant.id)!")
                        self.onBookingSuccess?(self.restaurant.id)
                        self.onDismiss?()
                    }
                }
            }
        } else {
            print("Thank You action triggered for \(restaurant.name)")
            self.onDismiss?()
        }
    }
}
