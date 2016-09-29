#ifndef MYMODELROW_H
#define MYMODELROW_H

#include <QObject>
#include <QMap>
#include "qganttmodelitem.h"

class myModelRow : public QObject
{
    Q_OBJECT
    //QMap<QGanttModelItem> m_row;

public:
    explicit myModelRow(QObject *parent = 0);

signals:

public slots:
};

#endif // MYMODELROW_H
