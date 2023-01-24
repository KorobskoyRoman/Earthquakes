//
//  QuakeDetail.swift
//  Earthquakes-iOS
//
//  Created by Roman Korobskoy on 23.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct QuakeDetail: View {
    var quake: Quake
    @EnvironmentObject private var quakesProvider: QuakesProvider
    @State private var location: QuakeLocation? = nil

    var body: some View {
        VStack {
            if let location = self.location {
                QuakeDetailMap(location: location, tintColor: quake.color)
                    .frame(height: 500)
                    .ignoresSafeArea(.container)
            }

            QuakeMagnitude(quake: quake)

            Text(quake.place)
                .font(.title3)
                .bold()
            Text("\(quake.time.formatted())")
                .foregroundStyle(Color.secondary)

            if let location = self.location {
                QuakeDetailLatLongView(location: location)
            }
        }
        .task {
            if self.location == nil {
                if let quakeLocation = quake.location {
                    self.location = quakeLocation
                } else {
                    self.location = try? await quakesProvider.location(for: quake)
                }
            }
        }
    }
}

struct QuakeDetailLatLongView: View {
    var location: QuakeLocation

    @State var latText = "Latitude: "
    @State var lonText = "Longitude: "
    @State var isFullPresicionLat = false
    @State var isFullPresicionLon = false

    var body: some View {
        Text(latText)
            .task {
                latText += "\(location.latitude)"
            }
            .onTapGesture {
                latText = "Latitude: \(isFullPresicionLat ? location.latitude.formatted(.number.precision(.fractionLength(3))) : "\(location.latitude)")"
                isFullPresicionLat.toggle()
            }
        Text(lonText)
            .task {
                lonText += "\(location.longitude)"
            }
            .onTapGesture {
                lonText = "Longitude: \(isFullPresicionLon ? location.longitude.formatted(.number.precision(.fractionLength(3))) : "\(location.longitude)")"
                isFullPresicionLon.toggle()
            }
    }
}

struct QuakeDetail_Previews: PreviewProvider {
    static var previews: some View {
        QuakeDetail(quake: Quake.preview)
    }
}
