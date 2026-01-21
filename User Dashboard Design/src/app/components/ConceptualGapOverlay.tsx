import { motion } from 'motion/react';
import { Brain, Clock, X } from 'lucide-react';

interface ConceptualGapOverlayProps {
  onDismiss: () => void;
}

export function ConceptualGapOverlay({ onDismiss }: ConceptualGapOverlayProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.3 }}
      className="fixed inset-0 z-50 flex items-center justify-center"
      style={{
        backdropFilter: 'blur(12px)',
        background: 'rgba(249, 249, 247, 0.8)'
      }}
      onClick={onDismiss}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        transition={{ duration: 0.4, ease: "easeOut" }}
        onClick={(e) => e.stopPropagation()}
        className="relative max-w-md mx-4 p-8 rounded-2xl"
        style={{
          background: '#ffffff',
          border: '1px solid rgba(10, 25, 47, 0.08)',
          boxShadow: '0 24px 64px rgba(10, 25, 47, 0.12)'
        }}
      >
        {/* Close button */}
        <button
          onClick={onDismiss}
          className="absolute top-4 right-4 p-2 rounded-lg opacity-40 hover:opacity-100 transition-opacity"
          style={{ color: '#0A192F' }}
        >
          <X className="w-5 h-5" />
        </button>

        {/* Icon */}
        <div
          className="flex items-center justify-center w-16 h-16 rounded-2xl mb-6 mx-auto"
          style={{
            background: 'linear-gradient(135deg, rgba(0, 240, 255, 0.1) 0%, rgba(10, 25, 47, 0.05) 100%)',
            border: '1px solid rgba(0, 240, 255, 0.2)'
          }}
        >
          <Brain className="w-8 h-8" style={{ color: '#0A192F', strokeWidth: 1.5 }} />
        </div>

        {/* Title */}
        <h3
          className="text-center mb-3"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-heading)',
            fontSize: '1.5rem'
          }}
        >
          Conceptual Gap Detected
        </h3>

        {/* Description */}
        <p
          className="text-center mb-6 leading-relaxed"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)',
            opacity: 0.7
          }}
        >
          Your inquiry touches on advanced concepts that may benefit from a focused review. 
          We recommend exploring foundational materials before proceeding.
        </p>

        {/* Time estimate */}
        <div
          className="flex items-center justify-center gap-2 mb-6 p-3 rounded-lg"
          style={{
            background: 'rgba(10, 25, 47, 0.03)',
            border: '1px solid rgba(10, 25, 47, 0.06)'
          }}
        >
          <Clock className="w-4 h-4" style={{ color: '#0A192F', opacity: 0.6 }} />
          <span
            className="text-sm"
            style={{
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)',
              opacity: 0.7
            }}
          >
            Focused Review Required • 3 mins
          </span>
        </div>

        {/* Action buttons */}
        <div className="flex gap-3">
          <button
            onClick={onDismiss}
            className="flex-1 px-4 py-3 rounded-lg transition-all duration-200"
            style={{
              background: 'rgba(10, 25, 47, 0.05)',
              color: '#0A192F',
              fontFamily: 'var(--font-family-body)',
              border: '1px solid rgba(10, 25, 47, 0.08)'
            }}
          >
            Continue Anyway
          </button>
          <button
            onClick={onDismiss}
            className="flex-1 px-4 py-3 rounded-lg transition-all duration-200"
            style={{
              background: 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)',
              color: '#00F0FF',
              fontFamily: 'var(--font-family-body)',
              border: 'none'
            }}
          >
            Start Review
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}
