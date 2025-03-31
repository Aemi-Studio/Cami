//
//  WidgetPreviewView.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import AppIntents
import SwiftUI

struct WidgetPreviewView: View {
    @State private var arePreviewSettingsOpen: Bool = false
    @State private var entry: StandardWidgetEntry?

    private let radius = 0.13333 * 170

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            if let entry {
                let configuration = entry.configuration

                DisclosureGroup {
                    CustomBordered(backgroundStyle: Color.primary.tertiary, outline: true) {
                        VStack(spacing: 8) {
                            WidgetEnumSetting(parameter: configuration.binding(for: \.complication))
                            Divider().padding(.horizontal, -16)
                            WidgetEnumSetting(parameter: configuration.binding(for: \.allDayStyle))
                            Divider().padding(.horizontal, -16)
                            WidgetBoolSetting(
                                title: "Group Similar Events",
                                parameter: configuration.binding(for: \.groupEvents)
                            )
                            Divider().padding(.horizontal, -16)
                            WidgetBoolSetting(
                                title: "Ongoing Events",
                                parameter: configuration.binding(for: \.showOngoingEvents)
                            )
                            Divider().padding(.horizontal, -16)
                            WidgetBoolSetting(
                                title: "Show Reminders",
                                parameter: configuration.binding(for: \.showReminders)
                            )
                            Divider().padding(.horizontal, -16)
                            WidgetBoolSetting(
                                title: "Mix Events & Reminders",
                                parameter: configuration.binding(for: \.useUnifiedList)
                            )
                            Divider().padding(.horizontal, -16)
                            WidgetBoolSetting(
                                title: "Header",
                                parameter: configuration.binding(for: \.showHeader)
                            )
                        }
                        .padding(.vertical, -8)
                    }
                } label: {
                    Text(String(localized: "view.widgetSettings.previewSection.title"))
                }
                .disclosureGroupStyle(CustomDisclosureGroupStyle(track: $arePreviewSettingsOpen))

                ForEach(WidgetSize.allCases) { widgetSize in
                    CustomSection {
                        Text(widgetSize.custom.description)
                    } content: {
                        CamiWidgetView(for: entry)
                            .frame(width: widgetSize.size.width, height: widgetSize.size.height)
                            .environment(\.customWidgetFamily, widgetSize.custom)
                            .background(Color(white: 0.1))
                            .clipShape(.rect(cornerRadius: radius))
                            .overlay {
                                RoundedRectangle(cornerRadius: radius)
                                    .fill(.clear)
                                    .stroke(Color.primary.quinary.opacity(0.5), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 3)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task { entry = .default }
        .animation(.default, value: arePreviewSettingsOpen)
    }
}

struct WidgetBoolSetting: View {
    let title: String
    @Binding var parameter: Bool

    var body: some View {
        Toggle(title, isOn: $parameter)
            .padding(.vertical, 9 / 2)
    }
}

struct WidgetEnumSetting<Parameter>: View
    where Parameter: AppEnum & LocalizedIntent & RawRepresentable<String>
{
    @Binding var parameter: Parameter
    var body: some View {
        HStack {
            Text(Parameter.localizedTitle)
            Spacer()
            WidgetConfigurationEnum(parameter: $parameter)
                .padding(.trailing, -13)
                .padding(.vertical, (17 / 3) / 2)
        }
    }
}

struct WidgetConfigurationEnum<Parameter>: View
    where Parameter: AppEnum & LocalizedIntent & RawRepresentable<String>
{
    @Binding var parameter: Parameter
    var body: some View {
        Picker(Parameter.localizedTitle, selection: $parameter) {
            ForEach(Array(Parameter.allCases), id: \.rawValue) { (option: Parameter) in
                Text(option.rawValue).tag(option)
            }
        }
    }
}

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    @Binding private(set) var track: Bool

    init(track state: Binding<Bool>? = nil) {
        _track = state ?? .constant(false)
    }

    func makeBody(configuration: Configuration) -> some View {
        CustomSection {
            Button {
                configuration.isExpanded.toggle()
            } label: {
                HStack {
                    configuration.label
                    Spacer()
                    Label("Toggle", systemImage: configuration.isExpanded ? "chevron.up" : "chevron.down")
                        .labelStyle(.iconOnly)
                        .font(.headline)
                }
                .contentShape(.rect)
            }.buttonStyle(.plain)
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                configuration.content
                    .frame(alignment: .top)
                    .clipped()
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxHeight: configuration.isExpanded ? .infinity : 0, alignment: .top)
            .opacity(configuration.isExpanded ? 1 : 0)
        }
        .padding(.bottom, configuration.isExpanded ? 0 : -16)
        .animation(.default, value: configuration.isExpanded)
        .onAppear {
            track = configuration.isExpanded
        }
        .onChange(of: configuration.isExpanded) { _, newValue in
            if track != newValue {
                track = newValue
            }
        }
    }
}
