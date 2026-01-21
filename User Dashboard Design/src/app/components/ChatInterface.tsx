import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChatMessage } from '@/app/components/ChatMessage';
import { VerticalDock } from '@/app/components/VerticalDock';
import { ResourceDock } from '@/app/components/ResourceDock';
import { InputArea } from '@/app/components/InputArea';
import { ConceptualGapOverlay } from '@/app/components/ConceptualGapOverlay';
import { ArrowLeft } from 'lucide-react';

interface Message {
  id: string;
  type: 'user' | 'ai';
  content: string;
  timestamp: Date;
  hasCode?: boolean;
  hasMath?: boolean;
}

interface ChatInterfaceProps {
  onBack: () => void;
  credits: number;
  maxCredits: number;
}

export function ChatInterface({ onBack, credits, maxCredits }: ChatInterfaceProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      type: 'user',
      content: 'The impact of dark matter on galaxy rotation',
      timestamp: new Date(Date.now() - 300000)
    },
    {
      id: '2',
      type: 'ai',
      content: `The influence of dark matter on galactic rotation curves represents one of the most compelling pieces of evidence for its existence. In classical Newtonian mechanics, we would expect orbital velocities to decrease with distance from the galactic center, following the relation v ∝ r^(-1/2).

However, observations reveal that rotation curves remain remarkably flat at large radii, suggesting the presence of an extended dark matter halo. This discrepancy can be understood through the virial theorem and the mass distribution within galaxies.

The observed flat rotation curves indicate that the enclosed mass M(r) grows linearly with radius, rather than remaining constant beyond the visible disk. This implies a density profile ρ(r) ∝ r^(-2) for the dark matter halo, consistent with NFW (Navarro-Frenk-White) profiles derived from cosmological simulations.`,
      timestamp: new Date(Date.now() - 290000),
      hasMath: true
    },
    {
      id: '3',
      type: 'user',
      content: 'Can you show me the mathematical formulation?',
      timestamp: new Date(Date.now() - 120000)
    },
    {
      id: '4',
      type: 'ai',
      content: `Certainly. The rotation curve is determined by the circular velocity at radius r, which for a spherically symmetric mass distribution is given by:

$$v_c(r) = \\sqrt{\\frac{GM(r)}{r}}$$

For a flat rotation curve where v_c = constant, we require:

$$M(r) \\propto r$$

This implies a density profile:

$$\\rho(r) = \\frac{1}{4\\pi r^2}\\frac{dM}{dr} \\propto \\frac{1}{r^2}$$

The NFW profile, which fits observational data well, is expressed as:

$$\\rho_{NFW}(r) = \\frac{\\rho_0}{\\frac{r}{r_s}(1 + \\frac{r}{r_s})^2}$$

where ρ₀ is a characteristic density and r_s is a scale radius. This profile naturally produces the observed flat rotation curves in the intermediate radial regime.`,
      timestamp: new Date(Date.now() - 110000),
      hasMath: true,
      hasCode: true
    }
  ]);

  const [showConceptualGap, setShowConceptualGap] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  const handleSendMessage = (content: string) => {
    const newMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      content,
      timestamp: new Date()
    };
    setMessages(prev => [...prev, newMessage]);
    
    // Simulate AI response
    setTimeout(() => {
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'ai',
        content: 'This is a simulated response. In a real implementation, this would connect to your AI research assistant.',
        timestamp: new Date()
      };
      setMessages(prev => [...prev, aiMessage]);
    }, 1000);
  };

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  return (
    <div 
      className="fixed inset-0 flex"
      style={{ background: '#F9F9F7' }}
    >
      {/* Header with back button and credits */}
      <div 
        className="fixed top-0 left-0 right-0 z-40 flex items-center justify-between px-6 py-4"
        style={{ 
          background: '#F9F9F7',
          borderBottom: '1px solid rgba(10, 25, 47, 0.06)'
        }}
      >
        <button
          onClick={onBack}
          className="flex items-center gap-2 opacity-60 hover:opacity-100 transition-opacity"
          style={{ 
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Research Desk</span>
        </button>

        <div
          className="px-4 py-1.5 rounded-full text-sm"
          style={{
            background: 'rgba(255, 255, 255, 0.6)',
            border: '1px solid rgba(10, 25, 47, 0.08)',
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          {credits} / {maxCredits} credits
        </div>
      </div>

      {/* Main content area - The Paper */}
      <div className="flex-1 flex justify-center pt-20 pb-32">
        <div 
          ref={scrollRef}
          className="w-full max-w-4xl px-8 overflow-y-auto scrollbar-thin"
          style={{
            scrollBehavior: 'smooth'
          }}
        >
          {/* Subtle paper border effect */}
          <div 
            className="py-8"
            style={{
              borderLeft: '1px solid rgba(10, 25, 47, 0.06)',
              borderRight: '1px solid rgba(10, 25, 47, 0.06)',
              paddingLeft: '2rem',
              paddingRight: '2rem'
            }}
          >
            {messages.map((message, index) => (
              <ChatMessage 
                key={message.id} 
                message={message}
                isLast={index === messages.length - 1}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Right Vertical Dock (Z2) */}
      <VerticalDock />

      {/* Resource Dock (Z3) */}
      <ResourceDock />

      {/* Input Area (Z1) */}
      <InputArea onSend={handleSendMessage} disabled={showConceptualGap} />

      {/* Conceptual Gap Overlay (Z4) */}
      <AnimatePresence>
        {showConceptualGap && (
          <ConceptualGapOverlay onDismiss={() => setShowConceptualGap(false)} />
        )}
      </AnimatePresence>

      {/* Demo button to trigger conceptual gap - subtle positioning */}
      {!showConceptualGap && (
        <button
          onClick={() => setShowConceptualGap(true)}
          className="fixed bottom-4 left-4 px-3 py-1.5 rounded-lg text-xs opacity-20 hover:opacity-50 transition-opacity"
          style={{
            background: '#0A192F',
            color: '#ffffff',
            fontFamily: 'var(--font-family-body)',
            fontSize: '0.75rem'
          }}
        >
          Demo Gap
        </button>
      )}
    </div>
  );
}