import { motion } from 'motion/react';
import { LayoutDashboard, Clock, User } from 'lucide-react';

const dockItems = [
  { id: 'dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { id: 'history', icon: Clock, label: 'History' },
  { id: 'profile', icon: User, label: 'Profile' }
];

export function VerticalDock() {
  return (
    <motion.div
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.5, delay: 0.3 }}
      className="fixed right-0 top-1/2 -translate-y-1/2 z-20"
      style={{
        background: 'rgba(255, 255, 255, 0.4)',
        backdropFilter: 'blur(12px)',
        border: '1px solid rgba(10, 25, 47, 0.08)',
        borderRight: 'none',
        borderTopLeftRadius: '12px',
        borderBottomLeftRadius: '12px',
        padding: '12px 8px',
        boxShadow: '0 4px 16px rgba(10, 25, 47, 0.06)'
      }}
    >
      <div className="flex flex-col gap-4">
        {dockItems.map((item, index) => (
          <motion.button
            key={item.id}
            whileHover={{ scale: 1.1, opacity: 1 }}
            whileTap={{ scale: 0.95 }}
            className="group relative flex items-center justify-center w-10 h-10 rounded-lg transition-all duration-200"
            style={{
              opacity: 0.6
            }}
            title={item.label}
          >
            <item.icon 
              className="w-5 h-5"
              style={{ 
                color: '#0A192F',
                strokeWidth: 1.5
              }}
            />
            
            {/* Tooltip */}
            <div
              className="absolute right-full mr-3 px-3 py-1.5 rounded-lg whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none"
              style={{
                background: '#0A192F',
                color: '#ffffff',
                fontFamily: 'var(--font-family-body)',
                fontSize: '0.8125rem'
              }}
            >
              {item.label}
            </div>
          </motion.button>
        ))}
      </div>
    </motion.div>
  );
}
