import { motion } from 'motion/react';
import { ArrowRight, Sparkles } from 'lucide-react';

export function ActiveTaskCard() {
  return (
    <div 
      className="relative rounded-2xl p-8 overflow-hidden cursor-pointer group"
      style={{
        background: 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)',
        boxShadow: '0 20px 60px rgba(10, 25, 47, 0.3), 0 8px 16px rgba(10, 25, 47, 0.2)'
      }}
    >
      {/* Decorative gradient overlay */}
      <div 
        className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{
          background: 'radial-gradient(circle at top right, rgba(0, 240, 255, 0.1), transparent 60%)'
        }}
      />
      
      {/* Content */}
      <div className="relative z-10">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles 
                className="w-5 h-5" 
                style={{ color: '#00F0FF' }}
              />
              <span 
                className="text-sm tracking-wider uppercase opacity-70"
                style={{ 
                  color: '#00F0FF',
                  fontFamily: 'var(--font-family-body)',
                  letterSpacing: '0.1em'
                }}
              >
                Active Project
              </span>
            </div>
            
            <h2 
              className="text-3xl mb-3"
              style={{ 
                color: '#ffffff',
                fontFamily: 'var(--font-family-heading)'
              }}
            >
              SolveLens AI: Physics Analysis
            </h2>
            
            <p 
              className="opacity-70 leading-relaxed mb-6"
              style={{ 
                color: '#ffffff',
                fontFamily: 'var(--font-family-body)',
                maxWidth: '600px'
              }}
            >
              Quantum mechanics problem solving with real-time step-by-step analysis. 
              Currently processing advanced wave function calculations and eigenvalue problems.
            </p>
            
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <div 
                  className="w-2 h-2 rounded-full animate-pulse"
                  style={{ backgroundColor: '#00F0FF' }}
                />
                <span 
                  className="text-sm"
                  style={{ 
                    color: '#00F0FF',
                    fontFamily: 'var(--font-family-body)'
                  }}
                >
                  12 queries today
                </span>
              </div>
              
              <div className="w-px h-4 bg-white opacity-20" />
              
              <span 
                className="text-sm opacity-60"
                style={{ 
                  color: '#ffffff',
                  fontFamily: 'var(--font-family-body)'
                }}
              >
                Last updated 23 min ago
              </span>
            </div>
          </div>
          
          <motion.div
            className="flex items-center justify-center w-12 h-12 rounded-full"
            style={{
              background: 'rgba(0, 240, 255, 0.15)',
              border: '1px solid rgba(0, 240, 255, 0.3)'
            }}
            whileHover={{ scale: 1.1 }}
            transition={{ type: "spring", stiffness: 400, damping: 17 }}
          >
            <ArrowRight 
              className="w-5 h-5"
              style={{ color: '#00F0FF' }}
            />
          </motion.div>
        </div>
        
        {/* Progress indicator */}
        <div 
          className="mt-6 h-1 rounded-full overflow-hidden"
          style={{ backgroundColor: 'rgba(255, 255, 255, 0.1)' }}
        >
          <motion.div
            className="h-full rounded-full"
            style={{ backgroundColor: '#00F0FF' }}
            initial={{ width: '0%' }}
            animate={{ width: '68%' }}
            transition={{ duration: 1, delay: 0.5, ease: "easeOut" }}
          />
        </div>
      </div>
    </div>
  );
}
