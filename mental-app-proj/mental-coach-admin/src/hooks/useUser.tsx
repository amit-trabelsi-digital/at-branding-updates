import { getAuth, onAuthStateChanged, User as FireUser } from "firebase/auth";
// import { User as FireUser, getAuth, onAuthStateChanged } from "firebase/auth";

import {
  createContext,
  Dispatch,
  ReactNode,
  SetStateAction,
  useContext,
  useEffect,
  useState,
} from "react";

export type AppUser = null | undefined | (FireUser & { isAdmin: boolean });

interface AuthContextType {
  user: AppUser;
  setUser: Dispatch<SetStateAction<AppUser>>;
  isLoading: boolean;
}

const UserContext = createContext<AuthContextType>({
  user: null,
  setUser: () => {},
  isLoading: true,
});

type Props = {
  children: ReactNode;
};

export const UserProvider = ({ children }: Props) => {
  const [user, setUser] = useState<AppUser>(undefined);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(getAuth(), async (user) => {
      if (user) {
        const tokenResult = await user.getIdTokenResult(true);
        const role = tokenResult.claims.role;
        setUser({ ...user, isAdmin: role === "0" || role === 0 });
      } else {
        setUser(null);
      }
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const contextValue = {
    user,
    setUser,
    isLoading,
  };

  return (
    <UserContext.Provider value={contextValue}>{children}</UserContext.Provider>
  );
};

// eslint-disable-next-line react-refresh/only-export-components
export function useUser() {
  return useContext(UserContext);
}
