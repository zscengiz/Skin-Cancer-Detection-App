import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Image, BackHandler } from 'react-native';
import { useRouter } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { jwtDecode } from 'jwt-decode';
import colors from '../../constants/Colors';
import fonts from '../../constants/fonts/fonts';
import images from '../../constants/images';

type JwtPayload = {
  name?: string;
  sub?: string;
  user_id?: string;
  exp?: number;
};

const HomeScreen = () => {
  const [userName, setUserName] = useState<string>('');
  const [weatherIcon, setWeatherIcon] = useState<string>('sun');

  const router = useRouter();

  useEffect(() => {
    const fetchUserName = async () => {
      const token = await AsyncStorage.getItem('accessToken');
      if (token) {
        const decoded = jwtDecode<JwtPayload>(token);
        setUserName(decoded?.name || '');
      }
    };
    fetchUserName();
  }, []);

  useEffect(() => {
    const backHandler = BackHandler.addEventListener('hardwareBackPress', () => true);
    return () => backHandler.remove();
  }, []);

  useEffect(() => {
    const randomIcon = ['sun', 'cloud', 'rain'][Math.floor(Math.random() * 3)];
    setWeatherIcon(randomIcon);
  }, []);

  const getWeatherImage = () => {
    switch (weatherIcon) {
      case 'sun':
        return images.sun;
      case 'cloud':
        return images.cloud;
      case 'rain':
        return images.rain;
      default:
        return images.sun;
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.profileContainer}>
        <Image source={images.profilePlaceholder} style={styles.profileImage} />
        <Text style={styles.profileName}>{userName ? `Hi, ${userName}` : 'Hi'}</Text>
      </View>

      <View style={styles.uvCard}>
        <Image source={getWeatherImage()} style={styles.weatherIcon} />
        <Text style={styles.uvTitle}>Current UV Index</Text>
        <Text style={styles.uvValue}>5.2</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: 20,
    paddingTop: 50,
  },
  profileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 30,
  },
  profileImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
  },
  profileName: {
    fontSize: 20,
    fontFamily: fonts.bold,
    color: colors.textPrimary,
  },
  uvCard: {
    backgroundColor: '#E0F2FE',
    borderRadius: 16,
    padding: 30,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 6,
  },
  weatherIcon: {
    width: 64,
    height: 64,
    marginBottom: 12,
    resizeMode: 'contain',
  },
  uvTitle: {
    fontSize: 18,
    color: colors.textSecondary,
    fontFamily: fonts.regular,
    marginBottom: 8,
  },
  uvValue: {
    fontSize: 40,
    fontFamily: fonts.bold,
    color: colors.primary,
  },
});

export default HomeScreen;