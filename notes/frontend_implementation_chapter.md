## 5.1 Development Tools and Technologies

Flutter was selected as the frontend framework for the system due to its ability to build modern, responsive, and visually consistent user interfaces from a single codebase. Its widget-based architecture simplified the implementation of different application modules for drivers, inspectors, and administrators while maintaining a unified design structure.

Dart was used as the programming language for frontend development because it is the native language of Flutter and provides strong support for structured programming, asynchronous operations, and maintainable application logic. Its seamless integration with Flutter helped accelerate interface development and state handling.

The `http` package was used to enable communication between the frontend application and the backend REST APIs. It was responsible for sending authentication requests and retrieving or updating data related to vehicles, parking sessions, fines, notifications, complaints, and administrative dashboard information.

`shared_preferences` was used to store authentication tokens locally on the device, allowing the application to preserve user sessions and reuse stored tokens when accessing protected endpoints. This helped improve usability and reduced the need for repeated login operations.

`flutter_map` was used to implement the map-based interface in the driver module, allowing geographic visualization of active parking sessions and clamped vehicles. It provided an efficient way to embed interactive maps within the application and support location-aware features.

The `latlong2` package was used alongside `flutter_map` to manage geographical coordinates and map positioning. It simplified the handling of latitude and longitude values required for rendering markers and centering map views.

`image_picker` was integrated to support inspector-related operations that require image input, such as capturing or selecting vehicle plate images and uploading evidence images during inspection and fine issuance processes. This improved the practicality of the inspection workflow.

Flutter localization support and right-to-left layout configuration were also used to ensure that the user interface matches the Arabic language requirements of the target users. This made the application more usable and culturally appropriate for the intended deployment environment.

Flutter’s built-in state handling mechanisms were also used throughout the frontend implementation. Instead of relying on an external state management framework such as Bloc or Provider, the system used StatefulWidget-based local state, callback-driven communication between screens, and asynchronous service calls to update the user interface. This approach kept the frontend lightweight and was appropriate for the project scale while still supporting clear separation between UI, services, and models.

## 5.2 System Setup and Project Structure

The frontend of the system was developed in a Windows environment using Flutter as the main application framework. Project dependencies were managed through Flutter’s package management system, and all required libraries were declared in the `pubspec.yaml` file to ensure consistent setup and reproducibility across different development machines.

The project follows a modular structure that separates shared configuration from feature-based implementation. The main application code is located in the `lib/` directory, which contains the core structure of the frontend system.

Within this structure, the `app/` directory defines the root application widget and global application-level configuration. The `core/` directory contains reusable infrastructure shared across the system, including API communication, token storage, and theme configuration. In particular, `api_client.dart` handles HTTP requests, `api_constants.dart` centralizes backend endpoint definitions, `token_storage.dart` manages local authentication token persistence, and `app_theme.dart` defines the visual theme of the application.

The `features/` directory contains the functional modules of the system, organized according to user roles and business capabilities. These modules include authentication, driver operations, inspector operations, and admin operations. Each feature is further divided into screens, services, and models in order to separate user interface rendering, backend communication logic, and data representation. This structure improves readability, maintainability, and scalability as the system evolves.

The application was also configured to support Arabic as the primary interface language, with right-to-left layout direction applied globally to match the target user environment. In addition, a centralized theme and shared styling approach were used to maintain a consistent visual identity across all application modules.

During development, the frontend application was run locally using Flutter development tools, which enabled hot reload and rapid testing of interface changes. The application was typically launched using the following command:

```bash
flutter run
```

## 5.3 Frontend Architecture

The frontend architecture of the system was designed using a modular, feature-based approach in order to achieve maintainability, clarity, and scalability. The application was not implemented as a single tightly coupled codebase; instead, it was divided into organized layers and feature modules, where each part is responsible for a specific role in the system. This structure made it easier to develop the application incrementally and to extend it later with additional functionality.

### Application Entry and Global Configuration

The application starts from `main.dart`, which launches the root widget of the system. The main application-level configuration is defined in the `app/` layer, where `MaterialApp` is initialized with the global theme, Arabic locale, and right-to-left layout direction. This setup ensures visual consistency and linguistic compatibility across all screens in the system.

### Core Layer

The `core/` directory contains the shared infrastructure used across multiple frontend modules. This layer includes the networking and configuration components that support the entire application. For example, `api_client.dart` handles HTTP communication, `api_constants.dart` centralizes API endpoint definitions, `token_storage.dart` manages local token persistence, and `app_theme.dart` provides the global visual theme. Placing these elements in a shared core layer reduces duplication and allows common functionality to be reused throughout the project.

### Feature-Based Organization

The main business functionality of the application is organized inside the `features/` directory. Each feature represents a separate functional domain of the system, such as authentication, driver operations, officer operations, and admin operations. This feature-based structure improves code organization by grouping related logic together rather than separating files only by technical type.

Within each feature, the code is further divided into the following parts:

- `screens/` or screen files: responsible for rendering the user interface and handling user interaction.
- `services/`: responsible for communicating with backend APIs and processing requests and responses.
- `models/`: responsible for representing structured data used by the frontend application.

This separation of concerns allows the interface layer to remain focused on presentation, while service classes handle backend communication and model classes define reusable data structures.

Although the frontend follows a modular structure, it does not rely on a centralized external state management framework. Screen-level state is managed primarily through Flutter’s built-in StatefulWidget mechanism, combined with service-based asynchronous updates and callback coordination between parent and child screens. This implementation strategy reduced architectural overhead while still supporting role-based workflows, dynamic data loading, and responsive user interaction.

### Interaction Flow Between Layers

The frontend follows a clear execution flow during runtime. When the user interacts with a screen, the screen triggers the appropriate service method. The service then communicates with the backend through the shared API client, receives the response, converts the returned data into model objects, and passes the processed result back to the user interface for rendering. This flow helps maintain clean boundaries between UI logic, communication logic, and data representation.

The interaction flow can be summarized as follows:

User Interaction -> Screen -> Service -> API Client -> Backend API -> Model Parsing -> UI Update

### Role-Based Navigation Architecture

The system also follows a role-based navigation structure. After successful authentication, the frontend determines the type of the logged-in user and redirects them to the appropriate module. Drivers are directed to the driver shell, inspectors to the officer shell, and administrators to the admin shell. Each shell acts as the main container for its corresponding workflows and screens, ensuring that each user role accesses only the functions relevant to its operational responsibilities.

Role detection after authentication was implemented as part of the frontend runtime flow. After the user submits valid login credentials, the frontend stores the returned access token locally, then requests the authenticated user profile from the backend in order to determine the current role. Based on this result, the application redirects the user to the corresponding shell interface: driver, inspector, or admin. This design ensures that navigation is controlled dynamically according to backend-confirmed permissions rather than fixed client-side assumptions.

### Architectural Benefits

This frontend architecture provided several practical benefits during development. It improved maintainability by separating responsibilities, simplified debugging by isolating concerns, and supported future scalability by allowing new modules and screens to be added without restructuring the whole project. It also created a consistent implementation pattern across the application, which made the development process more organized and easier to manage.

## 5.4 Frontend Implementation

The frontend of the system was implemented as a role-based Flutter application organized into separate feature modules for authentication, driver operations, inspector operations, and admin operations. Each module includes its own screens, service classes, and data models, while shared functionality such as API communication, token storage, and application styling is handled through the common core layer. The frontend communicates with the backend through REST APIs and uses local token storage to preserve authenticated sessions and control access to protected workflows.

### 5.4.1 Authentication and Role-Based Access

The authentication module handles user login, registration, and session initialization. The login interface allows users to enter their national ID and password, then sends the credentials to the backend authentication endpoint. After a successful login, the frontend stores the returned access token locally and requests the current user profile in order to determine the authenticated user’s role.

Based on the returned role, the user is redirected to the appropriate interface module. Drivers are redirected to the driver shell, inspectors are redirected to the officer shell, and administrators are redirected to the admin shell. This role-based navigation structure ensures that each user accesses only the screens and operations relevant to their permissions in the system.

The registration interface was also implemented as a multi-step frontend workflow. It collects personal information, vehicle information, and identity-related details in separate stages to improve usability and input organization. After successful registration, the frontend completes the required initialization flow by authenticating the user temporarily, submitting the associated vehicle data, and then returning the user to the login screen.

This authentication flow also supports session continuity across protected screens. Once the token is stored locally, the frontend reuses it when requesting secured backend resources such as profile information, vehicles, parking sessions, fines, and administrative data. When the user logs out, the stored token is cleared and access to these protected workflows is terminated until a new authenticated session is established.

### 5.4.2 Driver Module Implementation

The driver module was implemented as the main operational interface for regular users of the system. It is organized around a dedicated driver shell that provides access to the main driver workflows through a structured navigation layout. These workflows include parking session management, vehicle management, wallet operations, violations, complaints, notifications, activity history, map visualization, and profile management.

The home screen provides the driver with a summarized operational view of the account. It displays the current wallet balance, the active parking session when available, and quick access to important actions such as starting a parking session, extending it, ending it, opening the wallet, and viewing traffic violations. This design allows the user to reach the most frequently used functions with minimal navigation.

The vehicle management interface allows the driver to add, update, delete, and manage registered vehicles. The frontend provides dedicated forms for vehicle entry and modification, while also supporting the selection of vehicle-related attributes such as type and color. In addition, one of the registered vehicles can be marked as the default vehicle to simplify later parking operations.

Parking session functionality was implemented through a complete interaction flow that allows drivers to start, extend, and end parking sessions. When starting a session, the frontend collects the selected vehicle, duration, and location-related information, then submits the request to the backend. If a session is already active, the home interface reflects the current session details and allows the user either to extend the duration or terminate the session. This workflow provides a direct digital alternative to traditional parking control processes.

The driver module also relies on coordinated asynchronous updates between screens and backend-connected services. For example, after starting, extending, or ending a parking session, the frontend refreshes the related wallet balance, active session state, and relevant screen content in order to keep the displayed account information synchronized with backend updates. This helped maintain consistency across the driver experience without requiring duplicated business logic inside the UI layer.

The wallet module was implemented to support balance-based operations in the app. It provides the user with a clear view of the current wallet balance as well as a transaction history screen showing previous financial activities. The frontend also supports wallet top-up operations through a guided charging flow, allowing the user to add credit that can later be used for parking fees and fine payments.

The violations module allows drivers to view all recorded traffic violations associated with their account. Each violation can be opened in a detailed screen showing its status, amount, vehicle plate number, and other related information. If a violation is unpaid, the frontend provides the ability to initiate the payment process directly from the application. The driver can also proceed from the violation details screen to submit a complaint or objection related to a specific fine.

The complaints module was implemented to support the submission and follow-up of driver complaints. The frontend allows users to create complaints by specifying the complaint type and description, while also displaying previously submitted complaints in a structured list. This module improves user interaction with the system by providing a digital channel for dispute handling and feedback submission.

The notifications module provides a centralized screen for displaying user notifications generated by the system. Notifications can be loaded from the backend and marked as read after being opened by the user. This ensures that drivers remain informed about important account events such as parking-related updates, financial actions, or enforcement-related changes.

The history module was implemented to display a consolidated activity record for the driver. It brings together relevant account actions such as parking sessions, transactions, and fines in a unified list. Each activity item can be opened in a separate details screen, allowing the user to inspect the full context of the selected event.

The map module was implemented using a map-based interface to provide geographic visibility into operational parking-related data. Through this screen, drivers can view active parking sessions and clamped vehicles on an interactive map. This visual approach improves spatial awareness and enhances the practical usability of the system within a real city environment.

Finally, the driver profile module provides access to personal account information and profile-related actions. Through this module, users can view their data, update profile information, change their password, configure account-related preferences, and log out from the system. This completes the driver-facing frontend experience by combining operational features with account management capabilities.

### 5.4.3 Inspector Module Implementation

The inspector module was implemented to support field inspection operations and enforcement-related tasks. It is organized through a dedicated officer shell that provides access to the inspector home screen, inspection workflows, activity history, and profile information. This structure allows inspectors to interact with the system through a focused interface tailored to operational monitoring and enforcement.

The main inspection workflow begins with the vehicle checking interface. This screen allows the inspector either to enter a vehicle plate number manually or to use an image-based approach for plate acquisition. The frontend integrates image selection and camera input to support the practical needs of field usage, especially in situations where direct manual entry may be slower or less convenient.

After acquiring the plate number, the frontend sends the request to the backend and displays the returned vehicle status information. This includes whether the vehicle is registered, whether it has an active parking session, whether it is currently clamped, and any available contextual details such as type, color, location, or remaining session time. The result screen acts as the central decision point for the next enforcement action.

The frontend also supports vehicle plate extraction from images as part of the inspection flow. This functionality improves efficiency in real-world use by reducing reliance on manual typing and allowing inspectors to initiate checks directly from captured plate images. Once the plate is extracted, the system automatically continues to the vehicle verification process.

The inspection workflow also includes a backend-connected image processing sequence. When the inspector captures or selects an image of a vehicle plate, the frontend uploads the image to the corresponding backend endpoint, receives the extracted plate number, and then automatically continues to the vehicle verification process. Similarly, during fine issuance, evidence images can be uploaded first so that their returned URLs can be attached to the final violation submission request. This integration improves the practicality of field operations and reduces dependence on repeated manual data entry.

The fine issuance interface was implemented as a dedicated workflow that allows the inspector to select a violation type, attach optional evidence imagery, and submit the violation together with location-related data. This design ensures that the frontend supports structured enforcement input and aligns with the operational requirements of digital fine registration.

In addition to fines, the inspector module includes clamp management functionality. Through the clamp interface, inspectors can register a clamp event for a vehicle by entering the required information such as plate number, reason, vehicle type, color, and location context. The system also provides an unclamp operation, allowing previously clamped vehicles to be released through the application interface when required.

The inspector module further includes a history screen that presents recorded activity in a single organized view. This allows inspectors to review previously processed operations and navigate through stored action records. A profile screen was also implemented to display the inspector’s account information and provide session-related actions such as logout. Together, these components form a complete operational frontend for inspection staff.

### 5.4.4 Admin Module Implementation

The admin module was implemented to provide supervisory and monitoring functionality for municipal administration users. It is accessed through a dedicated admin shell that separates administrative workflows from driver and inspector operations. The frontend design of this module emphasizes overview, monitoring, and management tasks rather than individual field actions.

The central element of the admin interface is the dashboard screen. This screen presents a high-level operational summary of the system, including active parking sessions, recorded fines, clamp events, daily revenue, and inspector performance indicators. By aggregating these figures into a single interface, the dashboard enables administrators to monitor the system state efficiently and identify important operational trends.

The admin frontend also includes an inspector management module. Through this screen, administrators can add new inspectors by entering their required account information through a structured form. The same administrative area also presents inspector-related operational information, allowing the municipality to monitor active personnel and maintain role-specific system access.

In addition to the dashboard and inspector management, the admin shell includes dedicated sections for complaints, map monitoring, and account-related administration. These interfaces are intended to provide centralized access to broader supervisory functions within the system and support future administrative extension without changing the general structure of the frontend.

In addition to the dashboard and inspector management, the admin frontend includes operational monitoring sections for complaints, fines, clamp event records, and map-based supervision. These sections allow administrative users to review submitted complaints, inspect recorded violations, monitor clamp-related activity, and observe geographic operational data through a structured interface. This organization supports the municipality’s supervisory role without mixing administrative functions with driver or inspector workflows.

The admin module was also designed to support responsive presentation behavior. On larger screens, the layout can present administrative content in a broader dashboard-oriented format, while smaller screens preserve navigability through a compact application structure. This improves usability for administration workflows across different device sizes and usage contexts.

The admin module was also implemented with a more responsive and dashboard-oriented presentation style compared to the driver and inspector mobile workflows. On larger screens, the administrative interface uses broader content containers and top-level navigation to support monitoring and management tasks more effectively. This makes the municipality-facing interface more suitable for web-style supervision scenarios, where overview and control are more important than rapid field interaction.

## 5.5 API Communication and Session Management

The frontend of the Mawqifi system was designed to communicate continuously with backend REST APIs in order to load, submit, and update application data across all user modules. Rather than embedding endpoint logic directly inside interface code, network communication was centralized through shared service classes and reusable API utilities. This approach improved maintainability and created a consistent communication pattern across authentication, parking, wallet, enforcement, and admin-related workflows.

A shared API client layer was implemented to handle HTTP requests such as `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`. This layer provides a common mechanism for sending requests to the backend and receiving responses in a structured way. In addition, API endpoint paths were centralized in a dedicated constants file, allowing the frontend to manage backend routes from a single location and reducing the risk of duplication or inconsistency.

Most protected frontend operations rely on token-based communication. After a successful login, the returned access token is stored locally and reused in subsequent requests through the `Authorization` header. This mechanism allows the frontend to access protected resources such as user profile data, vehicles, parking sessions, fines, notifications, inspection functions, and administrative dashboard data while preserving the authenticated session state across screens.

Session management was implemented using local token persistence so that authentication data can remain available during the user’s interaction with the application. The frontend retrieves the stored token when needed, uses it for secure API access, and clears it when the user logs out. This process ensures that session continuity is maintained during normal use while also providing a clear way to terminate access when required.

Error handling was also considered as part of the communication layer. The frontend processes backend responses and displays meaningful feedback messages to the user whenever requests fail, authentication becomes invalid, or network access is interrupted. Timeout handling and translated error messages were used in multiple modules to improve usability and reduce ambiguity during failed operations.

The frontend also uses service-specific request handling rather than placing API logic directly inside the visual components. Each functional module communicates with its backend endpoints through dedicated service classes, which process request bodies, attach authorization tokens where required, parse the returned JSON data into model objects, and forward the processed result back to the screen layer. This structure reduces repetition and improves maintainability across the system’s multiple user roles.

Overall, the API communication and session management design helped the frontend remain organized, secure, and consistent. By separating communication logic from interface rendering and managing authentication state centrally, the application was able to support multiple user roles and operational workflows in a controlled and scalable manner.

## 5.6 User Interface Design and Arabic Localization

The user interface of the Mawqifi frontend was designed to provide a clear, structured, and accessible experience for the different categories of system users. Since the application serves drivers, inspectors, and administrators, the interface design was organized in a way that balances usability with role-specific functionality. Each module was given a focused navigation structure so that users can reach their main tasks quickly without unnecessary complexity.

A consistent visual identity was maintained throughout the application using a shared theme configuration. Common colors, card styles, form fields, buttons, and layout patterns were defined centrally and reused across the different screens. This helped establish a uniform look and feel across authentication interfaces, driver workflows, inspection screens, and administrative dashboards.

The frontend was also designed with Arabic language support as a primary requirement. The application was configured to use Arabic locale settings and right-to-left layout direction globally, ensuring that all interface elements match the reading and navigation behavior of the target users. This localization setup improved clarity and made the system more suitable for its intended operating environment.

Special attention was given to form design and interaction flow. Input screens such as login, registration, vehicle entry, fine issuance, and complaint submission were implemented using structured fields and guided steps where needed. This helped reduce input confusion and supported smoother completion of operational tasks.

Navigation was adapted according to module requirements. In user-facing mobile workflows, shell-based navigation and screen transitions were used to organize major functionalities such as home, history, vehicles, and profile management. In the admin module, the layout was designed to support broader content presentation and more dashboard-oriented interaction patterns, especially on larger screens.

Map-based and image-based interactions were also included as part of the interface design. The map screen provides a visual representation of geographic operational data, while the inspection module supports image selection and camera-based workflows for vehicle checking and evidence handling. These interactive features improved the practical usability of the application and aligned the interface with the real operational context of the system.

The interface design also reflects the difference between operational mobile workflows and supervisory administrative workflows. Driver and inspector interfaces were implemented with task-oriented screen flows suitable for direct field use, while the admin interface was structured in a broader dashboard-like style to better support monitoring, overview, and management activities. This distinction helped align the frontend presentation with the responsibilities and usage context of each role.

Overall, the frontend interface was implemented to be visually consistent, operationally clear, and linguistically appropriate for Arabic-speaking users. The combination of shared styling, role-based layouts, and right-to-left support contributed to a user experience that is both functional and context-aware.
