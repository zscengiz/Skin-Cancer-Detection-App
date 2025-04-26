import { Stack } from 'expo-router';

export default function Layout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="screens/OnboardingScreen" />
      <Stack.Screen name="screens/WelcomeScreen" />
      <Stack.Screen name="screens/LoadingScreen" />
      <Stack.Screen name="screens/HomeScreen" />
      <Stack.Screen name="screens/auth/LoginScreen" />
      <Stack.Screen name="screens/auth/SignUpScreen" />
      <Stack.Screen name="screens/auth/ForgotPasswordScreen" />
    </Stack>
  );
}
