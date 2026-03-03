import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { NgStyle } from '@angular/common';

export type AvatarInitialsSize = 'sm' | 'md' | 'lg';

const SIZE_MAP: Record<AvatarInitialsSize, { diameter: number; fontSize: number }> = {
  sm: { diameter: 24, fontSize: 10 },
  md: { diameter: 40, fontSize: 16 },
  lg: { diameter: 56, fontSize: 22 },
};

function hashString(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = str.charCodeAt(i) + ((hash << 5) - hash);
  }
  return hash;
}

function hslColor(hue: number): string {
  return `hsl(${hue}, 55%, 50%)`;
}

function relativeLuminance(r: number, g: number, b: number): number {
  const toLinear = (c: number): number => {
    const v = c / 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  };
  return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);
}

function hslToRgb(h: number, s: number, l: number): [number, number, number] {
  s /= 100;
  l /= 100;
  const a = s * Math.min(l, 1 - l);
  const f = (n: number): number => {
    const k = (n + h / 30) % 12;
    return l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1));
  };
  return [Math.round(f(0) * 255), Math.round(f(8) * 255), Math.round(f(4) * 255)];
}

function textColor(bg: string): string {
  const hslMatch = bg.match(/hsl\((\d+),\s*(\d+)%,\s*(\d+)%\)/);
  if (!hslMatch) return '#ffffff';
  const [r, g, b] = hslToRgb(
    parseInt(hslMatch[1], 10),
    parseInt(hslMatch[2], 10),
    parseInt(hslMatch[3], 10),
  );
  return relativeLuminance(r, g, b) > 0.35 ? '#111827' : '#ffffff';
}

@Component({
  selector: 'app-avatar-initials',
  standalone: true,
  imports: [NgStyle],
  templateUrl: './avatar-initials.component.html',
  styleUrl: './avatar-initials.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AvatarInitialsComponent {
  firstName = input.required<string>();
  lastName = input.required<string>();
  nickname = input.required<string>();
  size = input<AvatarInitialsSize>('md');

  protected readonly initials = computed(() => {
    const f = this.firstName()[0]?.toUpperCase() ?? '';
    const l = this.lastName()[0]?.toUpperCase() ?? '';
    return `${f}${l}`;
  });

  protected readonly backgroundColor = computed(() => {
    const hash = hashString(this.nickname());
    const hue = Math.abs(hash % 360);
    return hslColor(hue);
  });

  protected readonly foregroundColor = computed(() => textColor(this.backgroundColor()));

  protected readonly containerStyle = computed(() => {
    const { diameter, fontSize } = SIZE_MAP[this.size()];
    return {
      width: `${diameter}px`,
      height: `${diameter}px`,
      'font-size': `${fontSize}px`,
      'background-color': this.backgroundColor(),
      color: this.foregroundColor(),
    };
  });
}
