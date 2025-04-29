import 'dotenv/config';

export default {
  expo: {
    name: "SkinCancerApp",
    slug: "SkinCancerApp",
    version: "1.0.0",
    extra: {
      EXPO_PUBLIC_API_URL: process.env.EXPO_PUBLIC_API_URL
    }
  }
};
