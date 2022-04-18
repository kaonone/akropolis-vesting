export function toSeconds(dateString) {
  return Math.round(new Date(dateString) / 1000);
}