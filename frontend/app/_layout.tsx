import { Stack } from "expo-router";

export default function RootLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
      }}
    >
      <Stack.Screen name="(auth)/login" />
      <Stack.Screen name="(auth)/signup" />
      <Stack.Screen name="screens/WelcomeScreen" />
      <Stack.Screen name="screens/LoadingScreen" />
    </Stack>
  );
}
