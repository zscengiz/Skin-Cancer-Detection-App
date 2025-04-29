import Constants from 'expo-constants';

export const getBackendURL = (): string => {
  const url = Constants.expoConfig?.extra?.EXPO_PUBLIC_API_URL || "http://localhost:8000";
  console.log(`Backend URL: ${url}`);
  return url;
};
