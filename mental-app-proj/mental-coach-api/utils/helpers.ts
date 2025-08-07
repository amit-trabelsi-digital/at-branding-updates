import { IUserMatch, IUserTraining } from "../models/user-match-training-model";

export function getSeasonByDate(date = new Date()) {
  // Ensure we have a valid Date object
  const inputDate = new Date(date);
  if (isNaN(inputDate.getTime())) {
    throw new Error("Invalid date provided");
  }

  const year = inputDate.getFullYear();
  const month = inputDate.getMonth(); // 0 = Jan, 11 = Dec

  // Soccer season typically starts in August (month 7, since 0-based)
  if (month >= 7) {
    // August to December: part of the season starting this year
    return `${year}-${year + 1}`;
  } else {
    // January to July: part of the season that started last year
    return `${year - 1}-${year}`;
  }
}

// const matchesInSeason = await Match.find({ season: "2025-2026" });

export function findSoonestMatch(matches?: IUserMatch[] | IUserTraining[]): IUserTraining | IUserMatch | null {
  if (!matches || matches.length === 0) {
    console.log("%cMatches is empty", "color: cyan;");
    return null;
  }

  const today = new Date();
  let soonestMatch: IUserMatch | IUserTraining | null = null;

  // Filter for future matches only
  console.log("matches", matches);
  const futureMatches = matches.filter((match) => new Date(match.date) >= today && !match.isOpen);
  console.log("futureMatches", futureMatches);

  if (futureMatches.length === 0) {
    return null; // No future matches found
  }

  // Find the soonest future match
  soonestMatch = futureMatches.reduce((closest, current) => {
    if (!closest) return current;
    return new Date(current.date) < new Date(closest.date) ? current : closest;
  }, null as IUserMatch | IUserTraining | null);

  return soonestMatch;
}
