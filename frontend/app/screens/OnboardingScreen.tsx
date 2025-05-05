import React, { useRef, useState } from 'react';
import { View, Text, FlatList, StyleSheet, Dimensions, TouchableOpacity, Image } from 'react-native';
import { useRouter } from 'expo-router';
import colors from '../../constants/Colors';
import fonts from '../../constants/fonts/fonts';
import images from '../../constants/images';

const { width, height } = Dimensions.get('window');

const slides = [
  {
    id: '1',
    title: 'Skin Health Matters',
    description: 'Regularly check your skin to detect early signs of skin cancer.',
    image: images.doctor,
  },
  {
    id: '2',
    title: 'Spot the Danger Early',
    description: 'Early detection of abnormal moles can save lives.',
    image: images.heart,
  },
  {
    id: '3',
    title: 'AI-Powered Skin Analysis',
    description: 'Get quick and reliable analysis of suspicious skin lesions.',
    image: images.technology,
  },
  {
    id: '4',
    title: 'Preventive Care',
    description: 'Understand risk factors and take action before it\'s too late.',
    image: images.stethoscope,
  },
  {
    id: '5',
    title: 'Track Your Skin Changes',
    description: 'Monitor the evolution of moles and spots with ease.',
    image: images.skinProtection,
  },
  {
    id: '6',
    title: 'Your Health, Our Priority',
    description: 'We ensure your data is safe while helping you stay healthy.',
    image: images.safety,
  },
];


const OnboardingScreen = () => {
  const router = useRouter();
  const flatListRef = useRef<FlatList>(null);
  const currentIndex = useRef(0);
  const [viewableIndex, setViewableIndex] = useState(0);

  const handleNext = () => {
    if (currentIndex.current < slides.length - 1) {
      flatListRef.current?.scrollToIndex({ index: currentIndex.current + 1 });
    } else {
      router.replace('/screens/WelcomeScreen');
    }
  };

  const onViewableItemsChanged = ({ viewableItems }: any) => {
    if (viewableItems.length > 0) {
      currentIndex.current = viewableItems[0].index;
      setViewableIndex(viewableItems[0].index);
    }
  };

  return (
    <View style={styles.container}>
      <FlatList
        ref={flatListRef}
        data={slides}
        keyExtractor={item => item.id}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onViewableItemsChanged={onViewableItemsChanged}
        scrollEnabled={false}
        renderItem={({ item }) => (
          <View style={styles.slide}>
            <Image source={item.image} style={styles.image} />
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.description}>{item.description}</Text>
          </View>
        )}
      />
      <TouchableOpacity style={styles.button} onPress={handleNext}>
        <Text style={styles.buttonText}>
          {viewableIndex === slides.length - 1 ? 'Get Started' : 'Next'}
        </Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    justifyContent: 'center',
  },
  slide: {
    width: width,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  image: {
    width: width * 0.7,
    height: height * 0.4,
    resizeMode: 'contain',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontFamily: fonts.bold,
    color: colors.primary,
    textAlign: 'center',
    marginBottom: 12,
  },
  description: {
    fontSize: 16,
    fontFamily: fonts.regular,
    color: colors.textSecondary,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  button: {
    backgroundColor: colors.primary,
    paddingVertical: 14,
    paddingHorizontal: 48,
    borderRadius: 30,
    position: 'absolute',
    bottom: 40,
  },
  buttonText: {
    color: colors.secondary,
    fontSize: 16,
    fontFamily: fonts.bold,
  },
});

export default OnboardingScreen;
