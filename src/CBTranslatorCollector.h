#ifndef CBTRANSLATORCOLLECTOR_H
#define CBTRANSLATORCOLLECTOR_H


class CBTranslatorCollector
        /*! \brief translations collector class
         * \details This class needs for collect untranslated phrases */
{
public:

    static CBTranslatorCollector *sharedInstance(){
        static CBTranslatorCollector *instance = NULL;
        if (!instance){
            instance = new CBTranslatorCollector();
        }
        return instance;
    }

private:
    CBTranslatorCollector();
};

#endif // CBTRANSLATORCOLLECTOR_H
