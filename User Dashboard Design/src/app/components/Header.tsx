import { motion } from 'motion/react';

interface HeaderProps {
  credits: number;
  maxCredits: number;
}

export function Header({ credits, maxCredits }: HeaderProps) {
  const now = new Date();
  const hour = now.getHours();
  let greeting = "Good Morning";
  
  if (hour >= 12 && hour < 17) {
    greeting = "Good Afternoon";
  } else if (hour >= 17) {
    greeting = "Good Evening";
  }
  
  return (
    <header className="flex items-center justify-between">
      <motion.h1 
        className="text-3xl"
        style={{ fontFamily: 'var(--font-family-heading)' }}
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.5 }}
      >
        {greeting}, <span className="opacity-70">Researcher.</span>
      </motion.h1>
      
      <motion.div
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.5 }}
        className="credit-pill relative px-6 py-2.5 rounded-full overflow-hidden"
        style={{
          background: 'rgba(255, 255, 255, 0.4)',
          backdropFilter: 'blur(12px)',
          border: '1px solid rgba(255, 255, 255, 0.3)',
          boxShadow: `0 0 20px rgba(0, 240, 255, 0.3), 
                      0 4px 12px rgba(10, 25, 47, 0.08),
                      inset 0 1px 1px rgba(255, 255, 255, 0.6)`
        }}
      >
        {/* Subtle glow effect */}
        <div 
          className="absolute inset-0 opacity-50"
          style={{
            background: 'radial-gradient(circle at 50% 50%, rgba(0, 240, 255, 0.15), transparent 70%)'
          }}
        />
        
        <div className="relative z-10 flex items-center gap-2">
          <span 
            className="font-semibold"
            style={{ 
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)'
            }}
          >
            {credits}
          </span>
          <span 
            className="opacity-60"
            style={{ color: '#0A192F' }}
          >
            / {maxCredits} Credits
          </span>
        </div>
      </motion.div>
    </header>
  );
}
