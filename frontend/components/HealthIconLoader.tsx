import React, { useEffect, useState } from 'react';
import { View, Image, StyleSheet } from 'react-native';
import images from '../constants/images';

const healthIcons = [
  images.heart,
  images.stethoscope,
  images.skinProtection,
  images.technology,
];

const HealthIconLoader = () => {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setIndex((prev) => (prev + 1) % healthIcons.length);
    }, 400);
    return () => clearInterval(interval);
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Image source={healthIcons[index]} style={styles.icon} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconContainer: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: 'black',
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 10,
  },
  icon: {
    width: 70,
    height: 70,
    resizeMode: 'contain',
  },
});

export default HealthIconLoader;
