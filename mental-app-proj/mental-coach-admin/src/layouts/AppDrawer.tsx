import {
  Box,
  Divider,
  Drawer,
  List,
  Link,
  ListItem,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  Chip,
} from "@mui/material";
import { Link as RouterLink, useLocation } from "react-router-dom";
import { adminRoutes, drawerWidth } from "../data/config";
import { ADMIN_VERSION, getEnvironment, getEnvironmentColor } from "../utils/version";

function AppDrawer() {
  const { pathname } = useLocation();

  const appBarTitle = adminRoutes.find(
    ({ href }: { href: string }) => pathname === href
  )?.title;

  return (
    <Drawer
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        "& .MuiDrawer-paper": {
          width: drawerWidth,
          boxSizing: "border-box",
        },
      }}
      variant="permanent"
      anchor="left" // right on hebrew
    >
      <Toolbar sx={{ display: "flex", justifyContent: "center" }}>
        <Link
          component={RouterLink}
          to="https://localhost:3000"
          target="_blank"
        >
          <Typography color={"primary"} variant="h1" fontWeight={700}>
            ניהול - המאמן המנטלי
          </Typography>
        </Link>
      </Toolbar>
      <Divider />
      <List>
        {adminRoutes.map(({ title, Icon, href }) => (
          <Link component={RouterLink} to={href} key={title}>
            <ListItem sx={{ bgcolor: appBarTitle === title ? "#eee" : "" }}>
              <ListItemIcon>
                <Icon />
              </ListItemIcon>
              <ListItemText sx={{ color: "#000" }} primary={title} />
            </ListItem>
          </Link>
        ))}
      </List>
      
      {/* קרדיט, גרסאות ותמיכה */}
      <Box sx={{ 
        position: 'absolute', 
        bottom: 0, 
        width: '100%', 
        p: 2, 
        borderTop: 1, 
        borderColor: 'divider',
        backgroundColor: 'background.paper'
      }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5, alignItems: 'center' }}>
          {/* סביבת הרצה */}
          <Chip 
            label={`סביבה: ${getEnvironment()}`} 
            color={getEnvironmentColor() as any} 
            size="small" 
            variant="outlined"
          />
          
          {/* גרסאות */}
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Typography variant="caption" color="text.secondary">
              ממשק: v{ADMIN_VERSION}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              •
            </Typography>
            <Typography variant="caption" color="text.secondary">
              API: v1.0.0
            </Typography>
          </Box>
          
          {/* לינק לתמיכה */}
          <Link
            component="button"
            onClick={() => window.dispatchEvent(new CustomEvent('openSupportDialog'))}
            sx={{ 
              textDecoration: 'none', 
              cursor: 'pointer',
              '&:hover': { textDecoration: 'underline' }
            }}
          >
            <Typography variant="caption" color="primary" align="center" display="block">
              צריך עזרה? פנה לתמיכה
            </Typography>
          </Link>
          
          {/* קרדיט */}
          <Link
            href="https://amit-trabelsi.co.il"
            target="_blank"
            rel="noopener noreferrer"
            sx={{ textDecoration: 'none' }}
          >
            <Typography variant="caption" color="text.secondary" align="center" display="block">
              פותח על ידי עמית טרבלסי
            </Typography>
          </Link>
        </Box>
      </Box>
    </Drawer>
  );
}

export default AppDrawer;
