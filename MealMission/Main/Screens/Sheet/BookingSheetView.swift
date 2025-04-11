import SwiftUI

struct BookingSheetView: View {

    // MARK: - State Object & Properties
    @StateObject private var viewModel: BookingSheetViewModel
    var onDismiss: () -> Void
    
    // MARK: - Initializer
    init(restaurant: Restaurant, mode: TargetMode, onDismiss: @escaping () -> Void, onBookingSuccess: ((String) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: BookingSheetViewModel(restaurant: restaurant, mode: mode, onDismiss: onDismiss, onBookingSuccess: onBookingSuccess))
        self.onDismiss = onDismiss
    }

    // MARK: - Private Constants
    private let sheetBackgroundColor = Color(red: 69/255, green: 71/255, blue: 82/255)
    private let inputBackgroundColor = Color(red: 36/255, green: 38/255, blue: 47/255)
    private let inputBorderColor: Color = .white
    private let semiTransparentBackground = Color.black.opacity(0.6)

    // MARK: - State Variables
    @State private var isDatePickerPresented = false
    @State private var isTimePickerPresented = false

    // MARK: - Body
    var body: some View {
        ZStack {
            semiTransparentBackground
                .edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .customFont( FontStyles.customRegular, size: 38)
                        }
                        .padding(.trailing, 15)
                        .padding(.bottom, 0)
                    }
                    
                    VStack(spacing: 20) {
                        Spacer(minLength: 20)

                        placeInfoSection
                            .padding(.horizontal, 20)

                        if !viewModel.showBookingControls {
                            Spacer()
                        }

                        Text(viewModel.titleText)
                            .customFont(.customRegular, size: viewModel.showBookingControls ? 34 : 20)
                            .foregroundColor(.customWhite)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        if viewModel.showBookingControls {
                            HStack(spacing: 15) {
                                datePickerSection
                                timePickerSection
                            }
                            .padding(.horizontal, 20)

                            customerPlacesSection
                        } else {
                            Spacer()
                        }

                        PrimaryActionButton(title: viewModel.actionButtonTitle, action: viewModel.primaryAction)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                    }
                    .background(sheetBackgroundColor)
                    .cornerRadius(50)
                    .frame(width: geometry.size.width - 10)
                    .aspectRatio(1.0 / 1.4, contentMode: .fit)
                    .clipped()
                    .scaleEffect(0.80)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        
        .sheet(isPresented: $isDatePickerPresented) {
            datePickerSheet
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $isTimePickerPresented) {
            timePickerSheet
                .presentationBackground(.ultraThinMaterial)
        }
    }

    // MARK: - Subviews

    private var placeInfoSection: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: viewModel.placeImageName)) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else if case .failure = phase {
                    Image(systemName: "photo.fill")
                        .resizable().scaledToFit().foregroundColor(.gray).padding()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 175, height: 175)
            .cornerRadius(30)
            .clipped()
            .padding(.bottom, 50)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.placeName)")
                    .customFont(.customSemiBold, size: 24)
                    .foregroundColor(.customWhite)
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text("Working time:")
                    .customFont(.customRegular, size: 16)
                    .foregroundColor(.customPlaceholderColor)
                Text(viewModel.workingHours)
                    .customFont(.customRegular, size: 18)
                    .foregroundColor(.customWhite)

                Spacer(minLength: 8)
                
                Text("How many times this restaurant was engaged in charity:")
                    .customFont(.customRegular, size: 16)
                    .foregroundColor(.customPlaceholderColor)
                StyledTextView(
                    text: viewModel.rating,
                    fontStyle: .customBold,
                    fontSize: 24
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 200)
    }

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data")
                .customFont(.customRegular, size: 16)
                .foregroundColor(.customWhite)

            HStack {
                 Text(viewModel.selectedDateString)
                     .customFont(.customRegular, size: FontSizes.form)
                     .foregroundColor(.customWhite)
                 Spacer()
             }
             .padding()
             .frame(maxWidth: .infinity, minHeight: 50)
             .background(inputBackgroundColor)
             .cornerRadius(10)
             .overlay(
                 RoundedRectangle(cornerRadius: 10)
                     .stroke(inputBorderColor, lineWidth: 1)
             )
             .contentShape(Rectangle())
             .onTapGesture {
                 isDatePickerPresented = true
             }
        }
    }

    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time")
                .customFont(.customRegular, size: 16)
                .foregroundColor(.customWhite)

            HStack {
                 Spacer()
                 Text(viewModel.selectedTimeString)
                     .customFont(.customRegular, size: FontSizes.form)
                     .foregroundColor(.customWhite)
                 Spacer()
             }
             .padding()
             .frame(maxWidth: .infinity, minHeight: 50)
             .background(inputBackgroundColor)
             .cornerRadius(10)
             .overlay(
                 RoundedRectangle(cornerRadius: 10)
                     .stroke(inputBorderColor, lineWidth: 1)
             )
             .contentShape(Rectangle())
             .onTapGesture {
                 isTimePickerPresented = true
             }
        }
    }

    private var customerPlacesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Customer's places")
                .customFont(.customRegular, size: 16)
                .foregroundColor(.customWhite)

            HStack {
                Button(action: viewModel.decrementPlaces) {
                    Image(systemName: "minus")
                        .foregroundColor(.customWhite)
                        .frame(width: 30, height: 30)
                }

                Spacer()
                Text("\(viewModel.customerPlaces)")
                    .customFont(.customRegular, size: FontSizes.form)
                    .foregroundColor(.customWhite)
                Spacer()

                Button(action: viewModel.incrementPlaces) {
                    Image(systemName: "plus")
                        .foregroundColor(.customWhite)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(inputBackgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Date/Time Picker Sheets
    private var datePickerSheet: some View {
        NavigationView {
             VStack {
                 DatePicker(
                     "Select Date",
                     selection: $viewModel.selectedDate,
                     in: Date()...,
                     displayedComponents: [.date]
                 )
                 .datePickerStyle(.graphical)
                 .labelsHidden()
                 .padding()

                 Spacer()
             }
             .navigationTitle("Select Date")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isDatePickerPresented = false
                    }
                 }
             }
         }
    }

    private var timePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: $viewModel.selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()

                Spacer()
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") {
                         isTimePickerPresented = false
                     }
                 }
             }
        }
    }
}

// MARK: - Preview
#Preview {
    let mockRestaurant = Restaurant(id: "prev1", name: "Preview Place", timeRange: "10-22", likesCount: 123, imageURL: "https://via.placeholder.com/300x400")
    BookingSheetView(restaurant: mockRestaurant, mode: .can, onDismiss: { print("Preview Dismiss") })
} 
