// Fixture: a clean React Native screen. Must produce zero hits.
import React from 'react';
import { Pressable, Text, View, StyleSheet, PlatformColor } from 'react-native';
import Animated, { FadeInDown, Easing } from 'react-native-reanimated';
import { Motion } from './motion';

export function CleanScreen({ title, items }: { title: string; items: string[] }) {
  return (
    <View style={styles.page}>
      <Text style={styles.title}>{title}</Text>
      {items.slice(0, 5).map((x, n) => (
        <Animated.View key={x} entering={FadeInDown.duration(Motion.enter).easing(Motion.curve)}>
          <Pressable accessibilityRole="button" style={styles.row}>
            <Text style={styles.body}>{x}</Text>
          </Pressable>
        </Animated.View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  page: { padding: 16, gap: 12, backgroundColor: PlatformColor('systemGroupedBackground') },
  title: { fontSize: 34, fontWeight: '600', color: PlatformColor('label') },
  row: { paddingVertical: 12, paddingHorizontal: 16, borderRadius: 12 },
  body: { fontSize: 17, color: PlatformColor('label') },
});

export const ease = Easing.out(Easing.cubic);

export const rowStyle = StyleSheet.create({
  // EXCEPTION to slop-grep/S23: hairline separators between rows of one grouped list are the system pattern
  divider: { borderBottomWidth: StyleSheet.hairlineWidth },
});
