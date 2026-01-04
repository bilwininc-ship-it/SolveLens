# SolveLens AI Integration Guide

## Architecture Overview

This integration follows Clean Architecture principles with three main layers:

### 1. Domain Layer (Business Logic)
- **Entities**: Core business objects (Question)
- **Repositories**: Abstract interfaces
- **Use Cases**: Business rules and operations

### 2. Data Layer (Implementation)
- **Models**: Data representations extending entities
- **Repositories**: Concrete implementations
- **Data Sources**: AI Service, Firestore

### 3. Presentation Layer (UI)
- **Providers**: State management
- **Screens**: UI components
- **Widgets**: Reusable UI elements

## Setup Instructions

### 1. Add Gemini API Key

Update \lib/core/constants/app_constants.dart\:

\\\dart
class AppConstants {
  static const String geminiApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';
  // ... rest of constants
}
\\\

### 2. Initialize Dependencies

In \main.dart\:

\\\dart
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup dependency injection
  await setupServiceLocator();
  
  runApp(const SolveLensApp());
}
\\\

### 3. Wrap App with Provider

\\\dart
class SolveLensApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SolutionProvider>(),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
\\\

## Usage Example

### Analyzing a Question

\\\dart
// In your widget
final provider = Provider.of<SolutionProvider>(context);

// Start analysis
await provider.analyzeQuestion(
  imageFile: capturedImage,
  userId: currentUser.id,
);

// Listen to state changes
if (provider.state is SolutionSuccess) {
  final question = (provider.state as SolutionSuccess).question;
  // Navigate to solution screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SolutionScreen(
        question: question.question,
        solution: question.answer,
        subject: question.subject,
      ),
    ),
  );
} else if (provider.state is SolutionError) {
  final error = provider.state as SolutionError;
  // Show error dialog
  if (error.isRateLimitError) {
    // Show premium upgrade dialog
  }
}
\\\

## State Management Flow

\\\
SolutionIdle
    
SolutionScanning (1.5s delay)
    
SolutionAnalyzing (progress updates)
    
SolutionSuccess / SolutionError
\\\

## Error Handling

### Rate Limit Error
\\\dart
if (error.isRateLimitError) {
  // Show subscription screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SubscriptionScreen(),
    ),
  );
}
\\\

### Blurry Image Error
\\\dart
if (error.isBlurryImage) {
  // Show tips dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Image Quality Tips'),
      content: Text('• Ensure good lighting\\n• Hold camera steady\\n• Focus on the question'),
    ),
  );
}
\\\

## Performance Optimization

### Memory Management
- Image buffers are automatically cleaned after processing
- Use \dispose()\ on providers when no longer needed
- Firestore operations use indexed queries

### Rate Limiting
- Implement client-side daily limits based on subscription
- Cache recent questions to reduce API calls
- Use optimistic UI updates

## Testing

### Unit Tests
\\\dart
test('AnalyzeQuestionUseCase returns question on success', () async {
  final mockRepo = MockQuestionRepository();
  final useCase = AnalyzeQuestionUseCase(mockRepo);
  
  when(mockRepo.analyzeQuestion(any, any))
      .thenAnswer((_) async => Right(mockQuestion));
  
  final result = await useCase(
    imageFile: mockFile,
    userId: 'test-user',
  );
  
  expect(result.isRight(), true);
});
\\\

## Gemini API Best Practices

1. **Temperature**: Set to 0.4 for consistent, focused responses
2. **Token Limit**: 2048 tokens for detailed explanations
3. **Safety Settings**: Medium threshold for all categories
4. **Retry Logic**: Implement exponential backoff for transient failures
5. **Caching**: Cache common questions to reduce API costs

## Firestore Data Structure

\\\
/questions/{questionId}
  - userId: string
  - imageUrl: string
  - question: string
  - answer: string
  - subject: string
  - createdAt: timestamp
\\\

### Indexes Required
- Collection: questions
  - userId (Ascending) + createdAt (Descending)

## Monitoring & Analytics

Track these metrics:
- API call success/failure rates
- Average response times
- Error types distribution
- User question volume by subject
- Rate limit hits

## Cost Optimization

1. **Image Compression**: Compress images before API call
2. **Caching**: Store common questions
3. **Batch Operations**: Group Firestore writes
4. **CDN**: Use Cloud Storage CDN for images
5. **Rate Limiting**: Implement per-user quotas

## Security Considerations

- Never expose API keys in client code
- Use Firebase Security Rules for Firestore
- Implement server-side validation
- Rate limit API calls per user
- Sanitize user inputs before Firestore storage
