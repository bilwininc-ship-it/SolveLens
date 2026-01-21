import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Paperclip, FileText, Image, CheckCircle2, X } from 'lucide-react';

interface Resource {
  id: string;
  name: string;
  type: 'pdf' | 'image';
  status: 'analyzed' | 'referenced';
}

const mockResources: Resource[] = [
  { id: '1', name: 'Dark_Matter_Review.pdf', type: 'pdf', status: 'analyzed' },
  { id: '2', name: 'Galaxy_Rotation.pdf', type: 'pdf', status: 'referenced' },
  { id: '3', name: 'NFW_Profile_Diagram.png', type: 'image', status: 'analyzed' }
];

export function ResourceDock() {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className="fixed bottom-32 right-6 z-30">
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.9 }}
            transition={{ duration: 0.3, ease: "easeOut" }}
            className="absolute bottom-16 right-0 flex flex-col gap-2 mb-2"
          >
            {mockResources.map((resource, index) => (
              <motion.div
                key={resource.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.2, delay: index * 0.05 }}
                className="group flex items-center gap-3 px-4 py-3 rounded-lg min-w-[280px]"
                style={{
                  background: 'rgba(255, 255, 255, 0.95)',
                  backdropFilter: 'blur(12px)',
                  border: '1px solid rgba(10, 25, 47, 0.08)',
                  boxShadow: '0 4px 16px rgba(10, 25, 47, 0.1)'
                }}
              >
                <div
                  className="flex items-center justify-center w-10 h-10 rounded-lg flex-shrink-0"
                  style={{
                    background: 'rgba(10, 25, 47, 0.05)'
                  }}
                >
                  {resource.type === 'pdf' ? (
                    <FileText className="w-5 h-5" style={{ color: '#0A192F', strokeWidth: 1.5 }} />
                  ) : (
                    <Image className="w-5 h-5" style={{ color: '#0A192F', strokeWidth: 1.5 }} />
                  )}
                </div>

                <div className="flex-1 min-w-0">
                  <p
                    className="text-sm truncate mb-1"
                    style={{
                      color: '#0A192F',
                      fontFamily: 'var(--font-family-body)'
                    }}
                  >
                    {resource.name}
                  </p>
                  <div className="flex items-center gap-1.5">
                    <CheckCircle2 
                      className="w-3 h-3"
                      style={{ color: '#00F0FF' }}
                    />
                    <span
                      className="text-xs capitalize"
                      style={{
                        color: '#00F0FF',
                        fontFamily: 'var(--font-family-body)'
                      }}
                    >
                      {resource.status}
                    </span>
                  </div>
                </div>

                <button
                  className="opacity-0 group-hover:opacity-40 hover:opacity-100 transition-opacity"
                  style={{ color: '#0A192F' }}
                >
                  <X className="w-4 h-4" />
                </button>
              </motion.div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>

      <motion.button
        onClick={() => setIsExpanded(!isExpanded)}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        className="relative flex items-center justify-center w-14 h-14 rounded-full"
        style={{
          background: isExpanded 
            ? 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)'
            : '#ffffff',
          border: isExpanded ? 'none' : '1px solid rgba(10, 25, 47, 0.1)',
          boxShadow: isExpanded 
            ? '0 8px 24px rgba(10, 25, 47, 0.25), 0 0 20px rgba(0, 240, 255, 0.2)'
            : '0 4px 16px rgba(10, 25, 47, 0.08)'
        }}
      >
        <motion.div
          animate={{ rotate: isExpanded ? 45 : 0 }}
          transition={{ duration: 0.3 }}
        >
          <Paperclip 
            className="w-6 h-6"
            style={{ 
              color: isExpanded ? '#00F0FF' : '#0A192F',
              strokeWidth: 1.5
            }}
          />
        </motion.div>

        {!isExpanded && mockResources.length > 0 && (
          <div
            className="absolute -top-1 -right-1 flex items-center justify-center w-5 h-5 rounded-full text-xs"
            style={{
              background: '#00F0FF',
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)',
              fontWeight: 600
            }}
          >
            {mockResources.length}
          </div>
        )}
      </motion.button>
    </div>
  );
}
