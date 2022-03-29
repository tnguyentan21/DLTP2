
public virtual class TriggerHandler {
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;

    
    protected TriggerContext context;

    
    private Boolean isTriggerExecuting;

    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    public class TriggerHandlerException extends Exception {
    }

    
    public TriggerHandler() {
        this.setTriggerContext();
    }

    
    public virtual void run() {
        if (!validateRun()) {
            return;
        }

        addToLoopCount();

        switch on context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    
    
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    
    
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if (Trigger.isExecuting && !testMode) {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when BEFORE_UPDATE {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when BEFORE_DELETE {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when AFTER_INSERT {
                    context = TriggerContext.AFTER_INSERT;
                }
                when AFTER_UPDATE {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when AFTER_DELETE {
                    context = TriggerContext.AFTER_DELETE;
                }
                when AFTER_UNDELETE {
                    context = TriggerContext.AFTER_UNDELETE;
                }
            }
        } else if (ctx != null && testMode) {
            switch on ctx {
                when 'before insert' {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when 'before update' {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when 'before delete' {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when 'after insert' {
                    context = TriggerContext.AFTER_INSERT;
                }
                when 'after update' {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when 'after delete' {
                    context = TriggerContext.AFTER_DELETE;
                }
                when 'after undelete' {
                    context = TriggerContext.AFTER_UNDELETE;
                }
                when else {
                    throw new TriggerHandler.TriggerHandlerException(
                        'Unexpected trigger context set'
                    );
                }
            }
        }
    }

    
    
    protected void addToLoopCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName)
                .increment();
            if (exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException(
                    'Maximum loop count of ' +
                    String.valueOf(max) +
                    ' reached in ' +
                    handlerName
                );
            }
        }
    }

    
    
    protected Boolean validateRun() {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException(
                'Trigger handler called outside of Trigger execution'
            );
        }
        if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }

    
    
    private String getHandlerName() {
        return String.valueOf(this)
            .substring(0, String.valueOf(this).indexOf(':'));
    }

    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeInsert() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeUpdate() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeDelete() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterInsert() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUpdate() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterDelete() {
    }
    
    
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUndelete() {
    }

    
    
    private class LoopCount {
        private Integer max;
        private Integer count;

        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        
        public Boolean exceeded() {
            if (this.max < 0) {
                return false;
            }
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        
        public Integer getMax() {
            return this.max;
        }

        
        public Integer getCount() {
            return this.count;
        }

        
        public void setMax(Integer max) {
            this.max = max;
        }
    }

    
    
    public enum TriggerContext {
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE
    }
}
